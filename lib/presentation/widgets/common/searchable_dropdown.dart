import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemLabel;
  final String Function(T) itemValue;
  final void Function(T?) onChanged;
  final bool enabled;
  final int maxDisplayItems;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.itemLabel,
    required this.itemValue,
    required this.onChanged,
    this.selectedItem,
    this.enabled = true,
    this.maxDisplayItems = 15,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isOpen = false;
  List<T> _filteredItems = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items.take(widget.maxDisplayItems).toList();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isOpen) {
      _showOverlay();
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items.take(widget.maxDisplayItems).toList();
      } else {
        _filteredItems = widget.items
            .where(
              (item) => widget
                  .itemLabel(item)
                  .toLowerCase()
                  .contains(query.toLowerCase()),
            )
            .take(widget.maxDisplayItems)
            .toList();
      }
    });
    _updateOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    setState(() => _isOpen = true);

    _overlayEntry = OverlayEntry(builder: (context) => _buildOverlay());

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _selectItem(T? item) {
    widget.onChanged(item);
    _searchController.clear();
    _filterItems('');
    _removeOverlay();
    _focusNode.unfocus();
  }

  Widget _buildOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return Positioned(
      left: offset.dx,
      top: offset.dy + size.height + 4,
      width: size.width,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: ResponsiveUtils.getResponsiveHeight(
              context,
              phoneHeight: 200,
              tabletHeight: 250,
              desktopHeight: 300,
            ),
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field
              Padding(
                padding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: 8,
                  tabletValue: 10,
                  desktopValue: 12,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari ${widget.label.toLowerCase()}...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context) *
                            0.5,
                      ),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: ResponsiveUtils.getResponsivePaddingCustom(
                      context,
                      phoneValue: 8,
                      tabletValue: 10,
                      desktopValue: 12,
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 14,
                      tabletSize: 16,
                      desktopSize: 18,
                    ),
                  ),
                  onChanged: _filterItems,
                ),
              ),
              // Items list
              Flexible(
                child: _filteredItems.isEmpty
                    ? Padding(
                        padding: ResponsiveUtils.getResponsivePadding(context),
                        child: Text(
                          'Tidak ada ${widget.label.toLowerCase()} ditemukan',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 14,
                              tabletSize: 16,
                              desktopSize: 18,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            _filteredItems.length +
                            1, // +1 for "Tidak ada" option
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "Tidak ada" option
                            return _buildDropdownItem(
                              null,
                              'Tidak ada',
                              widget.selectedItem == null,
                            );
                          }

                          final item = _filteredItems[index - 1];
                          final isSelected =
                              widget.selectedItem != null &&
                              widget.selectedItem == item;

                          return _buildDropdownItem(
                            item,
                            widget.itemLabel(item),
                            isSelected,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownItem(T? item, String label, bool isSelected) {
    return InkWell(
      onTap: () => _selectItem(item),
      child: Container(
        padding: ResponsiveUtils.getResponsivePaddingCustom(
          context,
          phoneValue: 12,
          tabletValue: 14,
          desktopValue: 16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 14,
                    tabletSize: 16,
                    desktopSize: 18,
                  ),
                  color: isSelected ? AppColors.primary : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.primary,
                size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = widget.selectedItem != null
        ? widget.itemLabel(widget.selectedItem!)
        : widget.hint;

    return GestureDetector(
      onTap: () {
        if (_isOpen) {
          _removeOverlay();
        } else {
          _showOverlay();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 12,
                tabletSize: 14,
                desktopSize: 16,
              ),
              fontWeight: FontWeight.w500,
              color: AppColors.textGray,
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 4,
              tabletSpacing: 6,
              desktopSpacing: 8,
            ),
          ),
          Container(
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: 12,
              tabletValue: 14,
              desktopValue: 16,
            ),
            decoration: BoxDecoration(
              color: widget.enabled
                  ? AppColors.background
                  : AppColors.secondary,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
              border: Border.all(
                color: _isOpen ? AppColors.primary : AppColors.border,
                width: _isOpen ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedLabel,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 14,
                        tabletSize: 16,
                        desktopSize: 18,
                      ),
                      color: widget.selectedItem != null
                          ? AppColors.textDark
                          : AppColors.textGray,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textGray,
                    size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
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
