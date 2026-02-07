// lib/ui/profile/components/api_key_sheet.dart
// API Key configuration bottom sheet

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/groq_service.dart';
import '../../../services/haptic_service.dart';
import '../../theme/void_theme.dart';

/// Bottom sheet content for configuring the Groq API key
class ApiKeySheetContent extends StatefulWidget {
  final TextEditingController controller;

  const ApiKeySheetContent({super.key, required this.controller});

  @override
  State<ApiKeySheetContent> createState() => _ApiKeySheetContentState();
}

class _ApiKeySheetContentState extends State<ApiKeySheetContent> {
  bool _obscureText = true;
  bool _isValidating = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    final theme = VoidTheme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.bgCard.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: theme.borderSubtle),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: theme.textPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  _buildHeader(theme),
                  const SizedBox(height: 20),
                  _buildDescription(theme),
                  const SizedBox(height: 24),
                  _buildInputField(theme),
                  if (_errorMessage != null) _buildErrorBanner(),
                  const SizedBox(height: 24),
                  _buildActionButtons(theme),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(VoidTheme theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.key_rounded,
              color: Colors.orangeAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'GROQ API ACCESS',
          style: GoogleFonts.ibmPlexMono(
            fontSize: 13,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(VoidTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configure the neural engine.',
          style: GoogleFonts.ibmPlexSans(
            color: theme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your Groq Cloud API key to enable "Human Curator" mode for auto-tagging and detailed aesthetics.',
          style: GoogleFonts.ibmPlexSans(
            color: theme.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(VoidTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _errorMessage != null
              ? Colors.redAccent.withValues(alpha: 0.4)
              : theme.borderSubtle,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        style: GoogleFonts.ibmPlexMono(color: theme.textPrimary, fontSize: 13),
        onChanged: (_) {
          if (_errorMessage != null) {
            setState(() => _errorMessage = null);
          }
        },
        decoration: InputDecoration(
          hintText: 'gsk_8h9s...',
          hintStyle:
              GoogleFonts.ibmPlexMono(color: theme.textMuted, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon:
              Icon(Icons.password_rounded, size: 18, color: theme.textTertiary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: theme.textTertiary,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: GoogleFonts.ibmPlexMono(
                  color: Colors.redAccent,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(VoidTheme theme) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildGetKeyButton(theme),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: _buildConnectButton(theme),
        ),
      ],
    );
  }

  Widget _buildGetKeyButton(VoidTheme theme) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse('https://console.groq.com/keys');
        if (!await launchUrl(url)) {
          // ignore
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.textPrimary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GET KEY',
              style: GoogleFonts.ibmPlexMono(
                color: theme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new_rounded, size: 12, color: theme.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectButton(VoidTheme theme) {
    return GestureDetector(
      onTap: _isValidating ? null : () => _handleConnect(theme),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.textPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: theme.textPrimary.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 0),
          ],
        ),
        child: Center(
          child: _isValidating
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.bgCard,
                  ),
                )
              : Text(
                  'CONNECT',
                  style: GoogleFonts.ibmPlexMono(
                    color: theme.bgCard,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleConnect(VoidTheme theme) async {
    final key = widget.controller.text.trim();

    // Handle Disconnect
    if (key.isEmpty) {
      await GroqService.setApiKey('');
      if (mounted) {
        Navigator.pop(context);
        HapticService.success();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.link_off_rounded, color: theme.textSecondary, size: 18),
                const SizedBox(width: 12),
                Text(
                  'AI CORE OFFLINE',
                  style: GoogleFonts.ibmPlexMono(
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                      color: theme.textPrimary),
                ),
              ],
            ),
            backgroundColor: theme.bgCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.borderSubtle),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    // Validate Key
    setState(() => _isValidating = true);

    final isValid = await GroqService.validateApiKey(key);

    if (mounted) {
      setState(() => _isValidating = false);

      if (isValid) {
        await GroqService.setApiKey(key);
        if (mounted) {
          Navigator.pop(context);
          HapticService.success();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: Colors.greenAccent, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI CORE ONLINE',
                    style: GoogleFonts.ibmPlexMono(
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                        color: theme.textPrimary),
                  ),
                ],
              ),
              backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF0D1A0D) : const Color(0xFFE8F5E9),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    BorderSide(color: Colors.greenAccent.withValues(alpha: 0.2)),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        HapticService.heavy();
        setState(
            () => _errorMessage = 'Invalid API key. Please check and try again.');
      }
    }
  }
}
