import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

// ── AtlasFix Logo ─────────────────────────────────────────────────────────────
// Figma: "Atlas" in orange Poppins 700, "fix" in white on orange pill
class AtlasFixLogo extends StatelessWidget {
  const AtlasFixLogo({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Text('Atlas',
        style: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    32,
          fontWeight:  FontWeight.w700,
          color:       AppColors.primary,
          letterSpacing: -0.5,
        )),
      const SizedBox(width: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color:        AppColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text('fix',
          style: TextStyle(
            fontFamily:  'Poppins',
            fontSize:    22,
            fontWeight:  FontWeight.w700,
            color:       Colors.white,
          )),
      ),
    ],
  );
}

// ── Full-screen gradient background ───────────────────────────────────────────
// Figma: linear-gradient(180deg, rgba(252,90,21,0) 31.46%, rgba(252,90,21,0.3) 81.92%), #FFFFFF
class GradientBg extends StatelessWidget {
  final Widget child;
  const GradientBg({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width:  double.infinity,
    height: double.infinity,
    color:  AppColors.white,
    child: DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(child: child),
    ),
  );
}

// ── Rounded pill input ─────────────────────────────────────────────────────────
// Figma: border-radius: 30px, border: 1px solid #FC5A15, bg: rgba(245,248,249,0.1)
// content-padding: 12px 16px
class PillInput extends StatefulWidget {
  final String                label;
  final TextEditingController controller;
  final IconData?             icon;
  final bool                  isPassword;
  final TextInputType         keyboardType;
  final String?               error;
  final int                   maxLines;
  final bool                  readOnly;
  final VoidCallback?         onTap;
  final Widget?               trailing;
  final void Function(String)? onChanged;

  const PillInput({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.isPassword   = false,
    this.keyboardType = TextInputType.text,
    this.error,
    this.maxLines     = 1,
    this.readOnly     = false,
    this.onTap,
    this.trailing,
    this.onChanged,
  });

  @override
  State<PillInput> createState() => _PillInputState();
}

class _PillInputState extends State<PillInput> {
  bool _hide = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.maxLines > 1 ? null : 48,
          decoration: BoxDecoration(
            color:        AppColors.inputBg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.error != null ? AppColors.error : AppColors.primary,
              width: 1,
            ),
          ),
          child: Row(children: [
            if (widget.icon != null) ...[
              const SizedBox(width: 16),
              Icon(widget.icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
            ] else
              const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller:   widget.controller,
                obscureText:  widget.isPassword && _hide,
                keyboardType: widget.keyboardType,
                maxLines:     widget.isPassword ? 1 : widget.maxLines,
                readOnly:     widget.readOnly,
                onTap:        widget.onTap,
                onChanged:    widget.onChanged,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize:   14,
                  color:      AppColors.dark,
                ),
                decoration: InputDecoration(
                  hintText: widget.label,
                  hintStyle: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize:   14,
                    color:      AppColors.textHint,
                  ),
                  border:        InputBorder.none,
                  isDense:       true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: widget.maxLines > 1 ? 14 : 0,
                  ),
                ),
              ),
            ),
            if (widget.isPassword) ...[
              IconButton(
                icon: Icon(
                  _hide ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () => setState(() => _hide = !_hide),
              ),
            ] else if (widget.trailing != null) ...[
              widget.trailing!,
              const SizedBox(width: 8),
            ] else
              const SizedBox(width: 16),
          ]),
        ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(widget.error!,
              style: const TextStyle(color: AppColors.error, fontSize: 11)),
          ),
      ],
    );
  }
}

// ── Orange pill button ─────────────────────────────────────────────────────────
// Figma: background #FC5A15, border-radius 30px, font Public Sans 700 15px
class OrangeBtn extends StatelessWidget {
  final String       label;
  final VoidCallback? onPressed;
  final bool         loading;
  final double       height;

  const OrangeBtn({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.height  = 44,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width:  double.infinity,
    height: height,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:         AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.55),
        elevation:   0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: loading
        ? const SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
        : Text(label,
            style: const TextStyle(
              fontFamily:  'Public Sans',
              fontWeight:  FontWeight.w700,
              fontSize:    15,
              color:       Colors.white,
            )),
    ),
  );
}

// ── Dark pill button ───────────────────────────────────────────────────────────
// Figma: background #393C40, used for "S'inscrire avec l'application"
class DarkBtn extends StatelessWidget {
  final String       label;
  final Widget?      leading;
  final VoidCallback? onPressed;

  const DarkBtn({super.key, required this.label, this.leading, this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width:  double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],
        Text(label,
          style: const TextStyle(
            fontFamily:  'Public Sans',
            fontWeight:  FontWeight.w700,
            fontSize:    15,
            color:       Colors.white,
          )),
      ]),
    ),
  );
}

// ── White shadow button ────────────────────────────────────────────────────────
// Figma: white bg, box-shadow 0px 0px 10px rgba(0,0,0,0.15)
class WhiteBtn extends StatelessWidget {
  final String       label;
  final Widget       logo;
  final VoidCallback? onPressed;

  const WhiteBtn({super.key, required this.label, required this.logo, this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    width:  double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        logo,
        const SizedBox(width: 12),
        Text(label,
          style: const TextStyle(
            fontFamily:  'Public Sans',
            fontWeight:  FontWeight.w700,
            fontSize:    15,
            color:       AppColors.dark,
          )),
      ]),
    ),
  );
}

// ── "Précédent / Suivant" two-button row ──────────────────────────────────────
class NavRow extends StatelessWidget {
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final String        nextLabel;
  final bool          loading;
  final bool          showPrev;

  const NavRow({
    super.key,
    this.onPrev,
    this.onNext,
    this.nextLabel = 'Suivant',
    this.loading   = false,
    this.showPrev  = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showPrev) return OrangeBtn(label: nextLabel, onPressed: onNext, loading: loading);
    return Row(children: [
      Expanded(
        child: SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: onPrev,
            style: OutlinedButton.styleFrom(
              side:  const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Précédent',
              style: TextStyle(
                fontFamily:  'Public Sans',
                fontWeight:  FontWeight.w700,
                fontSize:    14,
              )),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: OrangeBtn(label: nextLabel, onPressed: onNext, loading: loading)),
    ]);
  }
}

// ── Error banner ───────────────────────────────────────────────────────────────
class ErrBanner extends StatelessWidget {
  final String msg;
  const ErrBanner(this.msg, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color:        AppColors.error.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border:       Border.all(color: AppColors.error.withOpacity(0.3)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline, color: AppColors.error, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(msg,
        style: const TextStyle(color: AppColors.error, fontSize: 12))),
    ]),
  );
}

// ── Footer link ("J'ai un compte ? Connexion") ────────────────────────────────
// Figma: font Public Sans 500 14px, link underlined orange
class FooterLink extends StatelessWidget {
  final String   prefix;
  final String   link;
  final VoidCallback onTap;

  const FooterLink({super.key, required this.prefix, required this.link, required this.onTap});

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontSize:   14,
            fontWeight: FontWeight.w500,
            color:      Colors.black,
          ),
          children: [
            TextSpan(text: prefix),
            TextSpan(text: link,
              style: const TextStyle(
                color:      AppColors.primary,
                decoration: TextDecoration.underline,
              )),
          ],
        ),
      ),
    ),
  );
}

// ── Scanner / file-picker row ─────────────────────────────────────────────────
// Figma: input with small orange "Scanner" pill on right
class ScanRow extends StatelessWidget {
  final String    hint;
  final IconData? icon;
  final String?   fileName;
  final String?   error;
  final String    btnLabel;
  final VoidCallback onTap;

  const ScanRow({
    super.key,
    required this.hint,
    required this.onTap,
    this.icon,
    this.fileName,
    this.error,
    this.btnLabel = 'Scanner',
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 48,
        decoration: BoxDecoration(
          color:        AppColors.inputBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: error != null ? AppColors.error : AppColors.primary),
        ),
        child: Row(children: [
          if (icon != null) ...[
            const SizedBox(width: 14),
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 6),
          ] else
            const SizedBox(width: 20),
          Expanded(child: Text(
            fileName ?? hint,
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize:   14,
              color: fileName != null ? AppColors.dark : AppColors.textHint,
            ),
            overflow: TextOverflow.ellipsis,
          )),
          GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(btnLabel,
                style: const TextStyle(
                  fontFamily:  'Public Sans',
                  fontWeight:  FontWeight.w700,
                  fontSize:    12,
                  color:       Colors.white,
                )),
            ),
          ),
        ]),
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 16),
          child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 11)),
        ),
    ],
  );
}

// ── Dropdown pill ──────────────────────────────────────────────────────────────
class PillDropdown extends StatelessWidget {
  final String       hint;
  final List<String> items;
  final String?      value;
  final String?      error;
  final IconData?    icon;
  final void Function(String?) onChanged;

  const PillDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.error,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color:        AppColors.inputBg,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: error != null ? AppColors.error : AppColors.primary),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value:      value,
            isExpanded: true,
            hint: Row(children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
              ],
              Text(hint,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: AppColors.textHint,
                )),
            ]),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14, color: AppColors.dark),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 16),
          child: Text(error!, style: const TextStyle(color: AppColors.error, fontSize: 11)),
        ),
    ],
  );
}

// ── Page title used on every auth screen ──────────────────────────────────────
class AuthTitle extends StatelessWidget {
  final String  title;
  final String? subtitle; // small orange subtitle below title (e.g. "Informations personnelles")

  const AuthTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AtlasFixLogo(),
      const SizedBox(height: 20),
      Text(title,
        style: const TextStyle(
          fontFamily:  'Poppins',
          fontSize:    28,
          fontWeight:  FontWeight.w500,
          color:       AppColors.dark,
          letterSpacing: -0.45,
        )),
      if (subtitle != null) ...[
        const SizedBox(height: 2),
        Text(subtitle!,
          style: const TextStyle(
            fontFamily:  'Public Sans',
            fontSize:    12,
            fontWeight:  FontWeight.w600,
            color:       AppColors.primary,
          )),
      ],
    ],
  );
}