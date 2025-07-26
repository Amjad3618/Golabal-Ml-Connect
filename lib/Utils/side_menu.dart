import 'package:flutter/material.dart';

import 'forms_&_menuitems.dart';

class SidebarMenuItem extends StatelessWidget {
  final MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarMenuItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? item.color.withOpacity(0.1) 
            : Colors.transparent,
        border: isSelected
            ? Border.all(color: item.color.withOpacity(0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected 
                ? item.color.withOpacity(0.2)
                : Colors.grey[100],
          ),
          child: Icon(
            item.icon,
            color: isSelected ? item.color : Colors.grey[600],
            size: 22,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: isSelected ? item.color : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: isSelected 
            ? Icon(
                Icons.arrow_forward_ios,
                color: item.color,
                size: 16,
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
