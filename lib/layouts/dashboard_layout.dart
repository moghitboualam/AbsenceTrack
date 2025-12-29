import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;
import '../services/auth_service.dart';
import 'sidebar_data.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;
  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      // L'AppBar affiche automatiquement l'icône du menu (Hamburger)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Bordure en bas pour garder le style précédent
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
        // Titre ou Logo au centre ou à gauche selon préférence
        title: const Text(
          "ENIAD-UMP",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(lucide.LucideIcons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              lucide.LucideIcons.logOut,
              color: Colors.red,
              size: 20,
            ),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      // Le Drawer remplace la Sidebar
      drawer: const AppDrawer(),
      backgroundColor: Colors.grey[50],
      body: child,
    );
  }
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Map<String, bool> _openItems = {};

  bool _isSectionSelected(BuildContext context, SidebarItem section) {
    final GoRouterState routerState = GoRouterState.of(context);
    final String currentLocation = routerState.uri.toString();

    if (section.url != null &&
        (currentLocation == section.url ||
            currentLocation.startsWith('${section.url}/'))) {
      return true;
    }

    if (section.items != null) {
      for (var item in section.items!) {
        if (item.url != null &&
            (currentLocation == item.url ||
                currentLocation.startsWith('${item.url}/'))) {
          return true;
        }
      }
    }
    return false;
  }

  void _handleNavigation(String url) {
    // Ferme le drawer avant de naviguer
    Navigator.pop(context);
    context.go(url);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final role = authService.user?.role ?? 'etudiant';
    final navMain = SidebarData.getNavMain(role);
    final navCollapsible = SidebarData.getNavCollapsible(role);

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // Header du Drawer
          _DrawerHeaderWidget(),

          // Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              children: [
                _buildNavList(navMain),
                if (navCollapsible.isNotEmpty) ...[
                  const Divider(height: 30),
                  ...navCollapsible.map(
                    (section) => _buildCollapsibleSection(section),
                  ),
                ],
              ],
            ),
          ),

          // User Profile Footer
          _UserProfileFooter(user: authService.user),
        ],
      ),
    );
  }

  Widget _buildNavList(List<SidebarItem> items) {
    return Column(
      children: items
          .map(
            (item) => _NavItemWidget(item: item, onNavigate: _handleNavigation),
          )
          .toList(),
    );
  }

  Widget _buildCollapsibleSection(SidebarItem section) {
    bool isOpen = _openItems[section.title] ?? false;

    return Column(
      children: [
        ListTile(
          onTap: section.url != null
              ? () => _handleNavigation(section.url!)
              : () => setState(() => _openItems[section.title] = !isOpen),
          leading: Icon(section.icon, size: 20),
          title: Text(
            section.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          trailing: section.items != null
              ? Icon(
                  isOpen
                      ? lucide.LucideIcons.chevronDown
                      : lucide.LucideIcons.chevronRight,
                  size: 16,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          dense: true,
          selected: _isSectionSelected(context, section),
          selectedTileColor: Colors.blue[50],
        ),
        if (isOpen)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _buildNavList(section.items!),
          ),
      ],
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final SidebarItem item;
  final Function(String) onNavigate;

  const _NavItemWidget({required this.item, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: item.url != null ? () => onNavigate(item.url!) : null,
      leading: Icon(item.icon, size: 20),
      title: Text(item.title, style: const TextStyle(fontSize: 14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      dense: true,
      selected: _isSelected(context, item.url),
      selectedTileColor: Colors.blue[50],
    );
  }

  bool _isSelected(BuildContext context, String? url) {
    if (url == null) return false;
    final GoRouterState routerState = GoRouterState.of(context);
    final String currentLocation = routerState.uri.toString();
    return currentLocation == url || currentLocation.startsWith('$url/');
  }
}

// Header spécifique au Drawer (similaire à UserAccountsDrawerHeader mais personnalisé)
class _DrawerHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Hauteur un peu plus grande pour le style
      padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: const Row(
        children: [
          Icon(lucide.LucideIcons.arrowUpCircle, color: Colors.blue, size: 30),
          SizedBox(width: 15),
          Text(
            "UMI FS",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _UserProfileFooter extends StatelessWidget {
  final dynamic user;
  const _UserProfileFooter({this.user});

  @override
  Widget build(BuildContext context) {
    final userName = user?.name ?? "Utilisateur";
    final userEmail = user?.email ?? "";
    final userInitial = userName.isNotEmpty
        ? userName.substring(0, 1).toUpperCase()
        : "U";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue[100],
            child: Text(userInitial),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (userEmail.isNotEmpty)
                  Text(
                    userEmail,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
