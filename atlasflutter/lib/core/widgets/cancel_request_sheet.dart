import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Bottom sheet for cancelling a request/offer matching the Figma design.
/// Returns `true` if the user confirmed the cancellation, `null`/`false` otherwise.
/// The optional [reason] text is available via the callback.
Future<bool?> showCancelRequestSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  ValueChanged<String>? onReasonProvided,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _CancelSheet(
      title: title,
      subtitle: subtitle,
      onReasonProvided: onReasonProvided,
    ),
  );
}

class _CancelSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final ValueChanged<String>? onReasonProvided;

  const _CancelSheet({
    required this.title,
    this.subtitle,
    this.onReasonProvided,
  });

  @override
  State<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<_CancelSheet> {
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title row + trash icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Annuler la demande',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color(0xFF191C24),
                        )),
                      if (widget.subtitle != null &&
                          widget.subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(widget.subtitle!,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 12,
                            color: Color(0xFF62748E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Warning icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444), size: 36),
            ),
            const SizedBox(height: 16),

            // Warning text
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF62748E),
                ),
                children: [
                  TextSpan(
                    text: 'Attention : ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  TextSpan(
                    text: 'Cette action supprimera définitivement\nvotre demande.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Reason label
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                  children: [
                    TextSpan(
                      text: "Raison de l'annulation ",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: '(optionnel)',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Reason text field
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFFD5C2), width: 1.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _reasonCtrl,
                maxLines: 3,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: Color(0xFF314158),
                ),
                decoration: const InputDecoration(
                  hintText: 'Lorem ipsum...',
                  hintStyle: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    color: Color(0xFFD1D5DC),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Keep
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFE5E7EB), width: 1.2),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Garder la demande',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Color(0xFF314158),
                        )),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Cancel
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        final reason = _reasonCtrl.text.trim();
                        if (reason.isNotEmpty) {
                          widget.onReasonProvided?.call(reason);
                        }
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Annuler la demande',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.white,
                        )),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
