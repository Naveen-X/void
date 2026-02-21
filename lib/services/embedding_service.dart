import 'dart:math' as math;import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

import 'tokenizer.dart';

/// Local embedding service using all-MiniLM-L6-v2 ONNX model.
/// Generates 384-dimensional sentence embeddings on device.
class EmbeddingService {
  static final WordPieceTokenizer _tokenizer = WordPieceTokenizer();
  static OrtSession? _session;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Initialize ONNX Runtime environment and load the model.
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize tokenizer
      await _tokenizer.init();
      if (!_tokenizer.isInitialized) {
        throw StateError('Tokenizer failed to initialize');
      }

      // Initialize ONNX Runtime
      OrtEnv.instance.init();

      // Load model from assets
      final rawAsset = await rootBundle.load('assets/models/model.onnx');
      final bytes = rawAsset.buffer.asUint8List();

      if (bytes.isEmpty) {
        throw StateError('Model file is empty');
      }

      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(bytes, sessionOptions);

      // Validate session loaded correctly
      if (_session == null) {
        throw StateError('Failed to create ONNX session');
      }

      // Log model input/output info for debugging
      debugPrint('EmbeddingService: Model inputs: ${_session!.inputNames}');
      debugPrint('EmbeddingService: Model outputs: ${_session!.outputNames}');

      _initialized = true;
      debugPrint('EmbeddingService: Initialized (model loaded)');
    } catch (e, st) {
      debugPrint('EmbeddingService: Init failed: $e');
      debugPrint('EmbeddingService: Stack: $st');
      _initialized = false;
      _session = null;
      rethrow;
    }
  }

  /// Generate a 384-dimensional embedding for the given text.
  /// Returns null if the service is not initialized or if embedding fails.
  static Future<List<double>?> embed(String text) async {
    if (!_initialized || _session == null) {
      debugPrint('EmbeddingService: Not initialized, cannot embed');
      return null;
    }

    // Guard: empty or blank text
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      debugPrint('EmbeddingService: Skipping empty text');
      return null;
    }

    // Clamp text length to avoid tokenizer issues (model max is 128 tokens)
    final safeText = trimmedText.length > 10000
        ? trimmedText.substring(0, 10000)
        : trimmedText;

    OrtValueTensor? inputIdsTensor;
    OrtValueTensor? attentionMaskTensor;
    OrtValueTensor? tokenTypeIdsTensor;
    OrtRunOptions? runOptions;
    List<OrtValue?>? outputs;

    try {
      // Tokenize
      final encoded = _tokenizer.encode(safeText);

      final inputIds = encoded['input_ids'];
      final attentionMask = encoded['attention_mask'];
      final tokenTypeIds = encoded['token_type_ids'];

      // Validate tokenizer output
      if (inputIds == null || attentionMask == null || tokenTypeIds == null) {
        debugPrint('EmbeddingService: Tokenizer returned null lists');
        return null;
      }

      if (inputIds.length != WordPieceTokenizer.maxLength ||
          attentionMask.length != WordPieceTokenizer.maxLength ||
          tokenTypeIds.length != WordPieceTokenizer.maxLength) {
        debugPrint('EmbeddingService: Tokenizer output length mismatch: '
            'ids=${inputIds.length}, mask=${attentionMask.length}, types=${tokenTypeIds.length}');
        return null;
      }

      // Validate no negative values in input_ids
      for (int i = 0; i < inputIds.length; i++) {
        if (inputIds[i] < 0) {
          debugPrint('EmbeddingService: Negative input_id at index $i: ${inputIds[i]}');
          return null;
        }
      }

      // Create ONNX tensors — shape [1, 128]
      final shape = [1, WordPieceTokenizer.maxLength];

      final int64InputIds = Int64List.fromList(
        inputIds.map((e) => e.toInt()).toList(),
      );
      final int64AttentionMask = Int64List.fromList(
        attentionMask.map((e) => e.toInt()).toList(),
      );
      final int64TokenTypeIds = Int64List.fromList(
        tokenTypeIds.map((e) => e.toInt()).toList(),
      );

      inputIdsTensor = OrtValueTensor.createTensorWithDataList(
        int64InputIds, shape,
      );
      attentionMaskTensor = OrtValueTensor.createTensorWithDataList(
        int64AttentionMask, shape,
      );
      tokenTypeIdsTensor = OrtValueTensor.createTensorWithDataList(
        int64TokenTypeIds, shape,
      );

      // Build input map using actual model input names
      final modelInputNames = _session!.inputNames;
      final inputs = <String, OrtValue>{};

      for (final name in modelInputNames) {
        if (name == 'input_ids') {
          inputs[name] = inputIdsTensor;
        } else if (name == 'attention_mask') {
          inputs[name] = attentionMaskTensor;
        } else if (name == 'token_type_ids') {
          inputs[name] = tokenTypeIdsTensor;
        }
      }

      if (inputs.length != modelInputNames.length) {
        debugPrint('EmbeddingService: Input name mismatch. '
            'Model expects: $modelInputNames, we have: ${inputs.keys.toList()}');
        return null;
      }

      // Run inference SYNCHRONOUSLY (runAsync uses isolates which can crash
      // on some devices due to FFI pointer issues across isolate boundaries)
      runOptions = OrtRunOptions();
      outputs = _session!.run(runOptions, inputs);

      if (outputs.isEmpty) {
        debugPrint('EmbeddingService: No output from model');
        return null;
      }

      // Parse output
      final output = outputs.first;
      if (output == null) {
        debugPrint('EmbeddingService: First output is null');
        return null;
      }

      final data = output.value;
      List<double> embedding;

      if (data is List<List<List<double>>>) {
        // Shape [1, 128, 384]
        if (data.isEmpty || data[0].isEmpty) {
          debugPrint('EmbeddingService: Empty output tensor');
          return null;
        }
        embedding = _meanPool(data[0], attentionMask);
      } else if (data is List) {
        // Flatten and try to parse
        final flat = _flatten(data);
        const hiddenSize = 384;
        final seqLen = WordPieceTokenizer.maxLength;

        if (flat.isEmpty) {
          debugPrint('EmbeddingService: Flattened output is empty');
          return null;
        } else if (flat.length == seqLen * hiddenSize) {
          // Reshape [128, 384]
          final tokenEmbeddings = <List<double>>[];
          for (int i = 0; i < seqLen; i++) {
            tokenEmbeddings.add(flat.sublist(i * hiddenSize, (i + 1) * hiddenSize));
          }
          embedding = _meanPool(tokenEmbeddings, attentionMask);
        } else if (flat.length == hiddenSize) {
          // Already pooled
          embedding = flat;
        } else {
          debugPrint('EmbeddingService: Unexpected output size: ${flat.length} '
              '(expected ${seqLen * hiddenSize} or $hiddenSize)');
          return null;
        }
      } else {
        debugPrint('EmbeddingService: Unexpected output type: ${data.runtimeType}');
        return null;
      }

      // Validate embedding has no NaN/Inf values
      for (int i = 0; i < embedding.length; i++) {
        if (embedding[i].isNaN || embedding[i].isInfinite) {
          debugPrint('EmbeddingService: NaN/Inf in embedding at index $i');
          return null;
        }
      }

      // L2 normalize
      return _l2Normalize(embedding);
    } catch (e, st) {
      debugPrint('EmbeddingService: Embedding failed: $e');
      debugPrint('EmbeddingService: Stack: $st');
      return null;
    } finally {
      // Always release tensors to prevent memory leaks
      try { inputIdsTensor?.release(); } catch (_) {}
      try { attentionMaskTensor?.release(); } catch (_) {}
      try { tokenTypeIdsTensor?.release(); } catch (_) {}
      try { runOptions?.release(); } catch (_) {}
      if (outputs != null) {
        for (final o in outputs) {
          try { o?.release(); } catch (_) {}
        }
      }
    }
  }

  /// Mean pooling: average token embeddings weighted by attention_mask
  static List<double> _meanPool(List<List<double>> tokenEmbeddings, List<int> attentionMask) {
    if (tokenEmbeddings.isEmpty) {
      debugPrint('EmbeddingService: Empty token embeddings in meanPool');
      return List<double>.filled(384, 0.0);
    }
    final hiddenSize = tokenEmbeddings.first.length;
    if (hiddenSize == 0) {
      return List<double>.filled(384, 0.0);
    }

    final result = List<double>.filled(hiddenSize, 0.0);
    double maskSum = 0.0;

    final len = math.min(tokenEmbeddings.length, attentionMask.length);

    for (int i = 0; i < len; i++) {
      final mask = attentionMask[i].toDouble();
      if (mask <= 0) continue; // skip padded tokens
      maskSum += mask;
      final tokenEmb = tokenEmbeddings[i];
      final tokenLen = math.min(tokenEmb.length, hiddenSize);
      for (int j = 0; j < tokenLen; j++) {
        result[j] += tokenEmb[j] * mask;
      }
    }

    if (maskSum > 0) {
      for (int j = 0; j < hiddenSize; j++) {
        result[j] /= maskSum;
      }
    }

    return result;
  }

  /// L2 normalize a vector
  static List<double> _l2Normalize(List<double> vec) {
    return l2NormalizePublic(vec);
  }

  /// Public L2 normalize for testing
  static List<double> l2NormalizePublic(List<double> vec) {
    if (vec.isEmpty) return vec;

    double norm = 0.0;
    for (final v in vec) {
      norm += v * v;
    }
    norm = math.sqrt(norm);

    if (norm == 0 || norm.isNaN || norm.isInfinite) return vec;

    return vec.map((v) => v / norm).toList();
  }

  /// Flatten arbitrarily nested lists to `List<double>`
  static List<double> _flatten(dynamic data) {
    if (data is double) return [data];
    if (data is num) return [data.toDouble()];
    if (data is List) {
      return data.expand<double>((e) => _flatten(e)).toList();
    }
    return [];
  }

  /// Cosine similarity between two normalized vectors.
  /// Since vectors are L2-normalized, cosine = dot product.
  static double cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a.length != b.length) {
      debugPrint('EmbeddingService: Dimension mismatch (${a.length} vs ${b.length})');
      return 0.0;
    }
    double dot = 0.0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  /// Release ONNX resources
  static void dispose() {
    try { _session?.release(); } catch (_) {}
    _session = null;
    try { OrtEnv.instance.release(); } catch (_) {}
    _initialized = false;
  }
}
