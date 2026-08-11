import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

const _classicHero = 'assets/images/games/flappy_bird/mode_classic_hero.png';
const _cyberHero = 'assets/images/games/flappy_bird/mode_cyber_hero.png';
const _classicTitle = 'assets/images/games/flappy_bird/title_classic.png';
const _cyberTitle = 'assets/images/games/flappy_bird/title_cyber.png';

class FlappyBirdSettingsScreen extends StatelessWidget {
  const FlappyBirdSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FlappyBirdSettingsController>();
    return Obx(() {
      final cyber = controller.currentTheme.value == FlappyBirdTheme.cyberpunk;
      final palette = _SettingsPalette(cyber);
      final compact = MediaQuery.sizeOf(context).height < 700;

      return Scaffold(
        backgroundColor: palette.background,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          decoration: BoxDecoration(gradient: palette.pageGradient),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: compact ? 250 : 310,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  child: Image.asset(
                    cyber ? _cyberHero : _classicHero,
                    key: ValueKey('settings-hero-$cyber'),
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -.5),
                    color: palette.heroTint,
                    colorBlendMode: BlendMode.srcATop,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: compact ? 255 : 315,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        palette.topShade,
                        Colors.transparent,
                        palette.background,
                      ],
                      stops: const [0, .42, 1],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _SettingsTopBar(palette: palette),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          MediaQuery.sizeOf(context).width < 360 ? 12 : 16,
                          compact ? 2 : 8,
                          MediaQuery.sizeOf(context).width < 360 ? 12 : 16,
                          MediaQuery.paddingOf(context).bottom + 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SettingsHero(
                              cyber: cyber,
                              palette: palette,
                              compact: compact,
                            ),
                            SizedBox(height: compact ? 12 : 18),
                            _SectionLabel(
                              title: 'SOUND & FEEDBACK',
                              icon: Icons.graphic_eq_rounded,
                              palette: palette,
                            ),
                            const SizedBox(height: 8),
                            _SettingsPanel(
                              palette: palette,
                              children: [
                                _ToggleRow(
                                  key: const Key('flappy-settings-sound'),
                                  icon: Icons.volume_up_rounded,
                                  title: 'Sound effects',
                                  subtitle: 'Flaps, scores and impacts',
                                  value: controller.soundEnabled.value,
                                  palette: palette,
                                  onChanged: (_) => controller.toggleSound(),
                                ),
                                _PanelDivider(palette: palette),
                                _ToggleRow(
                                  key: const Key('flappy-settings-music'),
                                  icon: Icons.music_note_rounded,
                                  title: 'Flight music',
                                  subtitle: 'Background soundtrack',
                                  value: controller.musicEnabled.value,
                                  palette: palette,
                                  onChanged: (_) => controller.toggleMusic(),
                                ),
                                _PanelDivider(palette: palette),
                                _ToggleRow(
                                  key: const Key('flappy-settings-haptics'),
                                  icon: Icons.vibration_rounded,
                                  title: 'Haptic feedback',
                                  subtitle: 'Tactile response on impact',
                                  value: controller.vibrationEnabled.value,
                                  palette: palette,
                                  onChanged: (_) =>
                                      controller.toggleVibration(),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 16 : 22),
                            _SectionLabel(
                              title: 'WORLD STYLE',
                              icon: Icons.tune_rounded,
                              palette: palette,
                            ),
                            const SizedBox(height: 8),
                            _FlightProfile(
                              controller: controller,
                              cyber: cyber,
                              palette: palette,
                            ),
                            SizedBox(height: compact ? 16 : 22),
                            _AboutCard(cyber: cyber, palette: palette),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SettingsTopBar extends StatelessWidget {
  const _SettingsTopBar({required this.palette});
  final _SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Material(
            color: palette.action,
            shape: CircleBorder(side: BorderSide(color: palette.actionBorder)),
            elevation: 4,
            shadowColor: Colors.black45,
            child: InkWell(
              onTap: Get.back,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.arrow_back_rounded,
                    color: palette.actionIcon, size: 24),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: palette.badge,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.cardBorder),
            ),
            child: Text(
              'FLIGHT CONTROL',
              style: TextStyle(
                color: palette.heading,
                fontFamily: 'BarlowCondensed',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({
    required this.cyber,
    required this.palette,
    required this.compact,
  });
  final bool cyber;
  final _SettingsPalette palette;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 112 : 145,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            width: compact ? 150 : 190,
            height: compact ? 64 : 82,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Image.asset(
                cyber ? _cyberTitle : _classicTitle,
                key: ValueKey('settings-title-$cyber'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: compact ? 5 : 8,
            child: Column(
              children: [
                Text(
                  'FLIGHT SETTINGS',
                  style: TextStyle(
                    color: palette.heroText,
                    fontFamily: 'BarlowCondensed',
                    fontSize: compact ? 24 : 29,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                    shadows: const [
                      Shadow(color: Colors.black38, blurRadius: 8),
                    ],
                  ),
                ),
                Text(
                  cyber ? 'TUNE YOUR NEON RUN' : 'MAKE THE SKY YOURS',
                  style: TextStyle(
                    color: palette.heroText.withValues(alpha: .78),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.icon,
    required this.palette,
  });
  final String title;
  final IconData icon;
  final _SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: palette.accent.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: palette.accent, size: 17),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            color: palette.heading,
            fontFamily: 'BarlowCondensed',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
      ],
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.palette, required this.children});
  final _SettingsPalette palette;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.palette,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final _SettingsPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: title,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: value
                      ? palette.accent.withValues(alpha: .14)
                      : palette.muted.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: value
                        ? palette.accent.withValues(alpha: .45)
                        : palette.cardBorder,
                  ),
                ),
                child: Icon(icon,
                    color: value ? palette.accent : palette.muted, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: palette.heading,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: palette.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _FlightSwitch(
                value: value,
                palette: palette,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlightSwitch extends StatelessWidget {
  const _FlightSwitch({
    required this.value,
    required this.palette,
    required this.onChanged,
  });
  final bool value;
  final _SettingsPalette palette;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: palette.accent,
      inactiveThumbColor: palette.muted,
      inactiveTrackColor: palette.inactiveTrack,
      trackOutlineColor: WidgetStatePropertyAll(palette.cardBorder),
    );
  }
}

class _PanelDivider extends StatelessWidget {
  const _PanelDivider({required this.palette});
  final _SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 66,
      endIndent: 14,
      color: palette.cardBorder,
    );
  }
}

class _FlightProfile extends StatelessWidget {
  const _FlightProfile({
    required this.controller,
    required this.cyber,
    required this.palette,
  });
  final FlappyBirdSettingsController controller;
  final bool cyber;
  final _SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
              color: palette.shadow,
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WORLD', style: palette.microLabel),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _ProfileChoice(
                  key: const Key('flappy-settings-classic'),
                  label: 'CLASSIC',
                  icon: Icons.wb_sunny_rounded,
                  selected: !cyber,
                  palette: palette,
                  onTap: () => controller.setTheme(FlappyBirdTheme.classic),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileChoice(
                  key: const Key('flappy-settings-cyber'),
                  label: 'CYBER',
                  icon: Icons.bolt_rounded,
                  selected: cyber,
                  palette: palette,
                  onTap: () => controller.setTheme(FlappyBirdTheme.cyberpunk),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileChoice extends StatelessWidget {
  const _ProfileChoice({
    super.key,
    required this.label,
    this.icon,
    required this.selected,
    required this.palette,
    required this.onTap,
  });
  final String label;
  final IconData? icon;
  final bool selected;
  final _SettingsPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 42,
        decoration: BoxDecoration(
          color: selected ? palette.accent : palette.choice,
          borderRadius: BorderRadius.circular(13),
          border:
              Border.all(color: selected ? palette.accent : palette.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: selected ? Colors.white : palette.muted, size: 16),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  color: selected ? Colors.white : palette.heading,
                  fontFamily: 'BarlowCondensed',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.cyber, required this.palette});
  final bool cyber;
  final _SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: double.infinity,
            child: Image.asset(
              cyber ? _cyberHero : _classicHero,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MASTER THE GAP',
                    style: TextStyle(
                      color: palette.heading,
                      fontFamily: 'BarlowCondensed',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap with rhythm, stay centered, and chase a new best.',
                    style: TextStyle(
                      color: palette.muted,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('GAMEVERSE · v2.0', style: palette.microLabel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPalette {
  _SettingsPalette(this.cyber);
  final bool cyber;

  Color get background =>
      cyber ? const Color(0xFF070C22) : const Color(0xFFFFFBED);
  Color get card => cyber ? const Color(0xF5121938) : const Color(0xFFFDFCF6);
  Color get choice => cyber ? const Color(0xFF0D1533) : const Color(0xFFF2F8F3);
  Color get heading =>
      cyber ? const Color(0xFFF6FAFF) : const Color(0xFF092A48);
  Color get muted => cyber ? const Color(0xFF91A1C8) : const Color(0xFF66798A);
  Color get accent => cyber ? const Color(0xFFFF2CAB) : const Color(0xFFFF7B22);
  Color get cardBorder =>
      cyber ? const Color(0xFF2D4172) : const Color(0xFFDCE5D8);
  Color get inactiveTrack =>
      cyber ? const Color(0xFF1F2A50) : const Color(0xFFD7DFDA);
  Color get action => cyber ? const Color(0xD90C1534) : const Color(0xFFFFF8E8);
  Color get actionBorder =>
      cyber ? const Color(0xFF25E6FF) : const Color(0xFFFFFFFF);
  Color get actionIcon =>
      cyber ? const Color(0xFF25E6FF) : const Color(0xFF092A48);
  Color get badge => cyber ? const Color(0xD90B1331) : const Color(0xEFFFF8E8);
  Color get heroText => Colors.white;
  Color get topShade =>
      cyber ? const Color(0xB8000312) : const Color(0x2B0873A6);
  Color get heroTint => cyber
      ? Colors.white.withValues(alpha: .78)
      : Colors.white.withValues(alpha: .88);
  Color get shadow => cyber ? const Color(0x66000000) : const Color(0x26123A48);

  LinearGradient get pageGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: cyber
            ? const [Color(0xFF05091D), Color(0xFF0A1230), Color(0xFF070C22)]
            : const [Color(0xFF56CFF2), Color(0xFFE4F7EA), Color(0xFFFFFBED)],
      );

  TextStyle get microLabel => TextStyle(
        color: muted,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: .9,
      );
}
