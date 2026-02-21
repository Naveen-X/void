import 'dart:convert';
import 'package:flutter/services.dart';

/// WordPiece tokenizer for all-MiniLM-L6-v2.
/// Parses the HuggingFace tokenizer.json and tokenizes text into input_ids,
/// attention_mask, and token_type_ids for ONNX inference.
class WordPieceTokenizer {
  late final Map<String, int> _vocab;
  late final int _unkId;
  late final int _clsId;
  late final int _sepId;
  late final int _padId;
  static const int maxLength = 128;
  static const String _subwordPrefix = '##';

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Load vocabulary from assets/models/tokenizer.json
  Future<void> init() async {
    if (_initialized) return;

    final jsonStr = await rootBundle.loadString('assets/models/tokenizer.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    final model = data['model'] as Map<String, dynamic>;
    final vocabMap = model['vocab'] as Map<String, dynamic>;

    _vocab = vocabMap.map((key, value) => MapEntry(key, value as int));

    _padId = _vocab['[PAD]'] ?? 0;
    _unkId = _vocab['[UNK]'] ?? 100;
    _clsId = _vocab['[CLS]'] ?? 101;
    _sepId = _vocab['[SEP]'] ?? 102;

    _initialized = true;
  }

  /// Tokenize text into model inputs.
  /// Returns {input_ids, attention_mask, token_type_ids} each as List<int>
  /// padded/truncated to [maxLength].
  Map<String, List<int>> encode(String text) {
    if (!_initialized) {
      throw StateError('Tokenizer not initialized. Call init() first.');
    }

    // Guard: empty text → just [CLS][SEP] with padding
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      final inputIds = List<int>.filled(maxLength, _padId);
      final attentionMask = List<int>.filled(maxLength, 0);
      final tokenTypeIds = List<int>.filled(maxLength, 0);
      inputIds[0] = _clsId;
      inputIds[1] = _sepId;
      attentionMask[0] = 1;
      attentionMask[1] = 1;
      return {
        'input_ids': inputIds,
        'attention_mask': attentionMask,
        'token_type_ids': tokenTypeIds,
      };
    }

    // 1. Normalize: lowercase, clean whitespace
    final normalized = _normalize(trimmed);

    // 2. Pre-tokenize: split on whitespace and punctuation (BertPreTokenizer)
    final words = _preTokenize(normalized);

    // 3. WordPiece tokenize each word
    final tokenIds = <int>[_clsId]; // Start with [CLS]

    for (final word in words) {
      final wordTokens = _wordPieceTokenize(word);
      // Check if adding this word would exceed maxLength - 1 (reserve space for [SEP])
      if (tokenIds.length + wordTokens.length >= maxLength - 1) {
        // Add as many tokens as we can
        final remaining = maxLength - 1 - tokenIds.length;
        tokenIds.addAll(wordTokens.take(remaining));
        break;
      }
      tokenIds.addAll(wordTokens);
    }

    tokenIds.add(_sepId); // End with [SEP]

    // 4. Pad to maxLength
    final inputIds = List<int>.filled(maxLength, _padId);
    final attentionMask = List<int>.filled(maxLength, 0);
    final tokenTypeIds = List<int>.filled(maxLength, 0);

    for (int i = 0; i < tokenIds.length; i++) {
      inputIds[i] = tokenIds[i];
      attentionMask[i] = 1;
    }

    return {
      'input_ids': inputIds,
      'attention_mask': attentionMask,
      'token_type_ids': tokenTypeIds,
    };
  }

  /// BertNormalizer: lowercase + clean whitespace
  String _normalize(String text) {
    // Lowercase
    var result = text.toLowerCase();

    // Replace control chars and multiple spaces with single space
    result = result.replaceAll(RegExp(r'[\x00-\x1f\x7f-\x9f]'), ' ');
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    result = result.trim();

    return result;
  }

  /// BertPreTokenizer: split on whitespace and punctuation
  List<String> _preTokenize(String text) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (_isWhitespace(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
      } else if (_isPunctuation(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(char);
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }

    return tokens;
  }

  /// WordPiece tokenization of a single word
  List<int> _wordPieceTokenize(String word) {
    if (word.length > 100) {
      return [_unkId]; // max_input_chars_per_word
    }

    final tokens = <int>[];
    int start = 0;

    while (start < word.length) {
      int end = word.length;
      int? foundId;

      while (start < end) {
        final substr = start > 0
            ? '$_subwordPrefix${word.substring(start, end)}'
            : word.substring(start, end);

        if (_vocab.containsKey(substr)) {
          foundId = _vocab[substr]!;
          break;
        }
        end--;
      }

      if (foundId == null) {
        return [_unkId]; // Whole word is unknown
      }

      tokens.add(foundId);
      start = end;
    }

    return tokens;
  }

  bool _isWhitespace(String char) {
    return char == ' ' || char == '\t' || char == '\n' || char == '\r';
  }

  bool _isPunctuation(String char) {
    final code = char.codeUnitAt(0);
    // ASCII punctuation ranges
    if ((code >= 33 && code <= 47) ||
        (code >= 58 && code <= 64) ||
        (code >= 91 && code <= 96) ||
        (code >= 123 && code <= 126)) {
      return true;
    }
    return false;
  }
}
