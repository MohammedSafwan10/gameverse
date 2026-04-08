# Update Dark Glassmorphic Cyberpunk Theme
# Run from c:\freela\gameverse directory

$files = @{
    "lib/screens/home/home_screen.dart" = @{
        replacements = @(
            # Update search bar to dark glassmorphic
            @{
                old = @"
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search your favorite game...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
"@
                new = @"
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 55,
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white,
        borderColor: AppTheme.primaryColor,
        borderRadius: 20,
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search your favorite game...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }
"@
            },
            # Update section titles to white text
            @{
                old = @"
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('See All', style: TextStyle(color: Colors.grey[500])),
        ),
      ],
    );
  }
"@
                new = @"
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('See All', style: TextStyle(color: AppTheme.primaryColor)),
        ),
      ],
    );
  }
"@
            },
            # Update quick play list - circles to dark glassmorphic
            @{
                old = @"
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(category.icon, color: color, size: 30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.title.split(' ')[0],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
"@
                new = @"
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: AppTheme.glassmorphicDecoration(
                      backgroundColor: color,
                      borderColor: color,
                      borderRadius: 32.5,
                    ),
                    child: Center(
                      child: Icon(category.icon, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.title.split(' ')[0],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
"@
            },
            # Update exit dialog to dark theme
            @{
                old = @"
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Exit GameVerse',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Text(
                'Are you sure you want to exit the app?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('EXIT'),
                ),
              ],
            );
          },
        ) ??
        false;
"@
                new = @"
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xFF1a1f3a),
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Exit GameVerse',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              content: Text(
                'Are you sure you want to exit the app?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL', style: TextStyle(color: AppTheme.primaryColor)),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('EXIT', style: TextStyle(color: Color(0xFF0a0e27))),
                ),
              ],
            );
          },
        ) ??
        false;
"@
            }
        )
    };
    "lib/screens/profile/profile_screen.dart" = @{
        replacements = @(
            # Update background to dark
            @{
                old = 'backgroundColor: Colors.grey[50],'
                new = 'backgroundColor: const Color(0xFF0a0e27),'
            },
            # Update header gradient (keep neon colors)
            @{
                old = @"
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withValues(alpha: 0.8),
                  primaryColor.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
"@
                new = @"
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withValues(alpha: 0.2),
                  primaryColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              border: Border(
                bottom: BorderSide(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
          ),
"@
            },
            # Update profile card to dark glassmorphic
            @{
                old = @"
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn()
              .scale(curve: Curves.elasticOut, duration: 800.ms),
          const SizedBox(height: 16),
          const Text(
            'Guest Player',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 4),
          Text(
            'Member since Feb 2026',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
"@
                new = @"
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white,
        borderColor: Theme.of(context).primaryColor,
        borderRadius: 30,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.black),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn()
              .scale(curve: Curves.elasticOut, duration: 800.ms),
          const SizedBox(height: 16),
          const Text(
            'Guest Player',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 4),
          Text(
            'Member since Feb 2026',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
"@
            },
            # Update stat cards to dark glassmorphic
            @{
                old = @"
  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2),
    );
  }
"@
                new = @"
  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: AppTheme.glassmorphicDecoration(
          backgroundColor: color,
          borderColor: color,
          borderRadius: 24,
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2),
    );
  }
"@
            },
            # Update menu section to dark glassmorphic
            @{
                old = @"
  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
            context,
            'My Achievements',
            Icons.workspace_premium_outlined,
            Colors.blue,
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuTile(
            context,
            'Game History',
            Icons.history_rounded,
            Colors.indigo,
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuTile(
            context,
            'Support Center',
            Icons.help_outline_rounded,
            Colors.teal,
            onTap: () => _showHelpSupportDialog(context),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }
"@
                new = @"
  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white,
        borderColor: AppTheme.primaryColor,
        borderRadius: 30,
      ),
      child: Column(
        children: [
          _buildMenuTile(
            context,
            'My Achievements',
            Icons.workspace_premium_outlined,
            const Color(0xFF00E5FF),
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuTile(
            context,
            'Game History',
            Icons.history_rounded,
            const Color(0xFFB400FF),
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuTile(
            context,
            'Support Center',
            Icons.help_outline_rounded,
            const Color(0xFF00FF88),
            onTap: () => _showHelpSupportDialog(context),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3);
  }
"@
            },
            # Update menu tile text color
            @{
                old = @"
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: Colors.grey),
"@
                new = @"
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: AppTheme.primaryColor.withValues(alpha: 0.6)),
"@
            },
            # Update divider
            @{
                old = 'return Divider(\n        height: 1, indent: 70, endIndent: 20, color: Colors.grey[100]);'
                new = 'return Divider(\n        height: 1, indent: 70, endIndent: 20, color: AppTheme.primaryColor.withValues(alpha: 0.15));'
            },
            # Update help dialog
            @{
                old = @"
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Help & Support',
            style: TextStyle(fontWeight: FontWeight.bold)),
"@
                new = @"
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        ),
        title: const Text('Help & Support',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
"@
            },
            # Update support option border
            @{
                old = 'border: Border.all(color: Colors.grey[200]!),'
                new = 'border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),'
            }
        )
    };
    "lib/widgets/category_card.dart" = @{
        replacements = @(
            # Update container to dark glassmorphic
            @{
                old = @"
        child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(
                    alpha: 0.4,
                  ),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
"@
                new = @"
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: primaryColor.withValues(alpha: 0.1),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(
                    alpha: 0.2,
                  ),
                  blurRadius: 20,
                  offset: Offset(0, 0),
                ),
              ],
            ),
"@
            }
        )
    };
    "lib/widgets/animated_game_card.dart" = @{
        replacements = @(
            # Update container to dark glassmorphic
            @{
                old = @"
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: 0,
              offset: const Offset(0, 0),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: Colors.white.withValues(alpha: 0.95),
"@
                new = @"
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.transparent,
          border: Border.all(
            color: color.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 40,
              offset: const Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: color.withValues(alpha: 0.08),
"@
            },
            # Update decorative circle gradient
            @{
                old = @"
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            color.withValues(alpha: 0.12),
                            color.withValues(alpha: 0),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
"@
                new = @"
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            color.withValues(alpha: 0.2),
                            color.withValues(alpha: 0),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
"@
            },
            # Update text styles - title in white
            @{
                old = @"
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 15,
                                    letterSpacing: -0.2,
                                    height: 1.2,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
"@
                new = @"
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 15,
                                    letterSpacing: -0.2,
                                    height: 1.2,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
"@
            },
            # Update subtitle text color
            @{
                old = @"
                                Text(
                                  isComingSoon
                                      ? 'Coming Soon'
                                      : '$gamesCount Games',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.black45,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
"@
                new = @"
                                Text(
                                  isComingSoon
                                      ? 'Coming Soon'
                                      : '$gamesCount Games',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
"@
            },
            # Update coming soon overlay
            @{
                old = @"
          Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lock_clock_rounded,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'SOON',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
"@
                new = @"
          Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: color.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_clock_rounded,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'SOON',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
"@
            }
        )
    }
}

# Apply replacements
foreach ($filePath in $files.Keys) {
    $fullPath = Join-Path -Path $PWD -ChildPath $filePath
    
    if (-not (Test-Path $fullPath)) {
        Write-Host "ERROR: File not found: $filePath" -ForegroundColor Red
        continue
    }
    
    $content = Get-Content $fullPath -Raw
    $originalContent = $content
    
    foreach ($replacement in $files[$filePath].replacements) {
        $content = $content -replace [regex]::Escape($replacement.old), $replacement.new
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $fullPath -Value $content -Encoding UTF8
        Write-Host "✓ Updated: $filePath" -ForegroundColor Green
    } else {
        Write-Host "⚠ No changes made to: $filePath (check replacement patterns)" -ForegroundColor Yellow
    }
}

Write-Host "