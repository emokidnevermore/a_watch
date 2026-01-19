import 'package:flutter/material.dart';

class EpisodeSelector extends StatefulWidget {
  final Map<String, dynamic> fileList;
  final Function(String episodeId) onEpisodeSelected;
  final String? currentEpisodeId;

  const EpisodeSelector({
    super.key,
    required this.fileList,
    required this.onEpisodeSelected,
    this.currentEpisodeId,
  });

  @override
  State<EpisodeSelector> createState() => _EpisodeSelectorState();
}

class _EpisodeSelectorState extends State<EpisodeSelector> {
  String? _selectedSeason;
  String? _selectedEpisode;
  String? _selectedTranslation;

  Map<String, dynamic> get _allSeasons =>
      widget.fileList['all'] as Map<String, dynamic>;

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  void _initializeSelection() {
    final active = widget.fileList['active'] as Map<String, dynamic>?;
    if (active != null) {
      _selectedSeason = active['seasons']?.toString();
      _selectedEpisode = active['episode']?.toString();
      _selectedTranslation = 't${active['id_translation']}';
    } else {
      _selectedSeason = _allSeasons.keys.first;
      final episodes = _allSeasons[_selectedSeason!] as Map<String, dynamic>;
      _selectedEpisode = episodes.keys.first;
      final translations = episodes[_selectedEpisode!] as Map<String, dynamic>;
      _selectedTranslation = translations.keys.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fileList['type'] != 'serial') {
      return const SizedBox.shrink();
    }

    final episodes = _allSeasons[_selectedSeason!] as Map<String, dynamic>;
    final translations = episodes[_selectedEpisode!] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Season selection if multiple
        if (_allSeasons.length > 1)
          _buildDropdown(
            label: 'Сезон',
            value: _selectedSeason,
            items: _allSeasons.keys.toList(),
            onChanged: (val) {
              setState(() {
                _selectedSeason = val;
                final newEpisodes = _allSeasons[val!] as Map<String, dynamic>;
                _selectedEpisode = newEpisodes.keys.first;
                _updateSelection();
              });
            },
          ),

        // Episode selection
        _buildHorizontalList(
          label: 'Серия',
          selectedValue: _selectedEpisode,
          items: episodes.keys.toList(),
          onChanged: (val) {
            setState(() {
              _selectedEpisode = val;
              _updateSelection();
            });
          },
        ),

        const SizedBox(height: 16),

        // Translation selection
        _buildHorizontalList(
          label: 'Озвучка',
          selectedValue: _selectedTranslation,
          items: translations.keys.toList(),
          itemLabel: (id) => (translations[id] as Map)['translation'] as String,
          onChanged: (val) {
            setState(() {
              _selectedTranslation = val;
              _updateSelection();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    String Function(String)? itemLabel,
    void Function(String?)? onChanged,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: TextStyle(color: textColor, fontSize: 16),
              dropdownColor: Colors.grey[900],
              underline: const SizedBox(),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    itemLabel != null ? itemLabel(item) : item,
                    style: TextStyle(color: textColor),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildHorizontalList({
    required String label,
    required String? selectedValue,
    required List<String> items,
    String Function(String)? itemLabel,
    void Function(String?)? onChanged,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final textColor = primaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: primaryColor),
                  onPressed: () {
                    final currentIndex = items.indexOf(selectedValue ?? '');
                    if (currentIndex > 0) {
                      onChanged?.call(items[currentIndex - 1]);
                    }
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        selectedValue != null && itemLabel != null
                            ? itemLabel(selectedValue)
                            : selectedValue ?? '',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: primaryColor),
                  onPressed: () {
                    final currentIndex = items.indexOf(selectedValue ?? '');
                    if (currentIndex < items.length - 1) {
                      onChanged?.call(items[currentIndex + 1]);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateSelection() {
    final episodes = _allSeasons[_selectedSeason!] as Map<String, dynamic>;
    final translations = episodes[_selectedEpisode!] as Map<String, dynamic>;

    // Safety check if translation doesn't exist for this ep
    if (!translations.containsKey(_selectedTranslation)) {
      _selectedTranslation = translations.keys.first;
    }

    final selectedData =
        translations[_selectedTranslation!] as Map<String, dynamic>;
    final id = selectedData['id']?.toString();
    if (id != null) {
      widget.onEpisodeSelected(id);
    }
  }
}
