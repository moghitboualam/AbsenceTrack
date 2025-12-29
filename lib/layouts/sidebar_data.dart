import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SidebarItem {
  final String title;
  final IconData icon;
  final String? url;
  final List<SidebarItem>? items;

  SidebarItem({required this.title, required this.icon, this.url, this.items});
}

class SidebarData {
  static List<SidebarItem> getNavMain(String role) {
    if (role == 'admin') {
      return [
        SidebarItem(
          title: "Dashboard",
          icon: LucideIcons.layoutDashboard,
          url: "/admin",
        ),
      ];
    } else if (role == 'enseignant') {
      return [
        SidebarItem(
          title: "Tableau de bord",
          icon: LucideIcons.home,
          url: "/enseignant",
        ),
        SidebarItem(
          title: "Mon Emploi du Temps",
          icon: LucideIcons.calendarClock,
          url: "/enseignant/edt",
        ),
      ];
    }
    return [
      SidebarItem(
        title: "Tableau de bord",
        icon: LucideIcons.home,
        url: "/etudiant",
      ),
      SidebarItem(
        title: "Mon emploi du temps",
        icon: LucideIcons.calendar,
        url: "/etudiant/emploi-du-temps",
      ),
      SidebarItem(
        title: "Mes absences",
        icon: LucideIcons.userX,
        url: "/etudiant/absences",
      ),
      SidebarItem(
        title: "Mes séances",
        icon: LucideIcons.presentation,
        url: "/etudiant/seances",
      ),
      SidebarItem(
        title: "Mes justifications",
        icon: LucideIcons.fileText,
        url: "/etudiant/justifications",
      ),
    ];
  }

  static List<SidebarItem> getNavCollapsible(String role) {
    if (role != 'admin') return [];
    return [
      SidebarItem(
        title: "Gestion Utilisateurs",
        icon: LucideIcons.userCog,
        items: [
          
          SidebarItem(
            title: "Enseignants",
            icon: LucideIcons.users,
            url: "/admin/enseignants",
          ),
          SidebarItem(
            title: "Étudiants",
            icon: LucideIcons.graduationCap,
            url: "/admin/etudiants",
          ),
        ],
      ),
      SidebarItem(
        title: "Structure Académique",
        icon: LucideIcons.school,
        items: [
          SidebarItem(
            title: "Départements",
            icon: LucideIcons.briefcase,
            url: "/admin/departements",
          ),
          SidebarItem(
            title: "Filières",
            icon: LucideIcons.school,
            url: "/admin/filieres",
          ),
          SidebarItem(
            title: "Modules",
            icon: LucideIcons.bookOpen,
            url: "/admin/modules",
          ),
          SidebarItem(
            title: "Promotions",
            icon: LucideIcons.graduationCap,
            url: "/admin/promotions",
          ),
          SidebarItem(
            title: "Planification",
            icon: LucideIcons.calendarCheck,
            url: "/admin/module-promotions",
          ),
          SidebarItem(
            title: "Emplois du temps",
            icon: LucideIcons.calendar,
            url: "/admin/emploi-du-temps",
          ),
          SidebarItem(
            title: "Blocs",
            icon: LucideIcons.box,
            url: "/admin/blocs",
          ),
          SidebarItem(
            title: "Salles",
            icon: LucideIcons.grid,
            url: "/admin/salles",
          ),
        ],
      ),
    ];
  }
}
