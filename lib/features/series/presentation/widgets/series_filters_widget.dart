import 'package:flutter/material.dart';
import 'package:a_watch/domain/entities/series_filters.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/features/home/presentation/widgets/single_select_dropdown_button.dart';
import 'package:a_watch/features/home/presentation/widgets/multi_select_dropdown_button.dart';

class SeriesFiltersWidget extends StatefulWidget {
  final SeriesFilters availableFilters;
  final SeriesFilters currentFilters;
  final ValueChanged<SeriesFilters> onFiltersChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onResetFilters;
  final bool isDesktop;

  const SeriesFiltersWidget({
    super.key,
    required this.availableFilters,
    required this.currentFilters,
    required this.onFiltersChanged,
    required this.onApplyFilters,
    required this.onResetFilters,
    required this.isDesktop,
  });

  @override
  State<SeriesFiltersWidget> createState() => _SeriesFiltersWidgetState();
}

class _SeriesFiltersWidgetState extends State<SeriesFiltersWidget> {
  late SeriesFilters _pendingFilters;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _pendingFilters = widget.currentFilters;
  }

  @override
  void didUpdateWidget(SeriesFiltersWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFilters != widget.currentFilters) {
      _pendingFilters = widget.currentFilters;
    }
  }

  Widget _buildDropdownFilter({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Add category-specific "reset" option at the beginning
    final allItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(hint, overflow: TextOverflow.ellipsis),
      ),
      ...items,
    ];

    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      child: SingleSelectDropdownButton(
        hint: hint,
        selectedValue: value,
        allItems: allItems,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMultiSelectDropdown({
    required String hint,
    required List<String> selectedValues,
    required List<String> allOptions,
    required ValueChanged<List<String>> onChanged,
  }) {
    final displayText = selectedValues.isEmpty
        ? hint
        : selectedValues.length == 1
            ? selectedValues.first
            : '${selectedValues.length} выбрано';

    return Container(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
      child: MultiSelectDropdownButton(
        hint: hint,
        displayText: displayText,
        selectedValues: selectedValues,
        allOptions: allOptions,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRangeSliderFilter({
    required String label,
    required double min,
    required double max,
    required RangeValues values,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBodyMedium('$label: ${values.start.round()} - ${values.end.round()}'),
        const SizedBox(height: 4),
        RangeSlider(
          min: min,
          max: max,
          values: values,
          onChanged: onChanged,
          divisions: (max - min).round(),
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Column(
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Тип контента
            _buildMultiSelectDropdown(
              hint: 'Тип',
              selectedValues: _pendingFilters.types.values.toList(),
              allOptions: widget.availableFilters.types.values.toList(),
              onChanged: (displayNames) {
                // Convert display names back to keys
                final selectedKeys = <String>[];
                for (final displayName in displayNames) {
                  final key = widget.availableFilters.types.entries
                      .firstWhere((entry) => entry.value == displayName,
                          orElse: () => const MapEntry('', ''))
                      .key;
                  if (key.isNotEmpty) {
                    selectedKeys.add(key);
                  }
                }
                setState(() {
                  _pendingFilters = _pendingFilters.copyWith(types: {
                    for (final key in selectedKeys)
                      key: widget.availableFilters.types[key] ?? key
                  });
                });
              },
            ),
            // Жанры
            _buildMultiSelectDropdown(
              hint: 'Жанр',
              selectedValues: _pendingFilters.genres.values.toList(),
              allOptions: widget.availableFilters.genres.values.toList(),
              onChanged: (displayNames) {
                final selectedKeys = <String>[];
                for (final displayName in displayNames) {
                  final key = widget.availableFilters.genres.entries
                      .firstWhere((entry) => entry.value == displayName,
                          orElse: () => const MapEntry('', ''))
                      .key;
                  if (key.isNotEmpty) {
                    selectedKeys.add(key);
                  }
                }
                setState(() {
                  _pendingFilters = _pendingFilters.copyWith(genres: {
                    for (final key in selectedKeys)
                      key: widget.availableFilters.genres[key] ?? key
                  });
                });
              },
            ),
            // Статус
            _buildMultiSelectDropdown(
              hint: 'Статус',
              selectedValues: _pendingFilters.statuses.values.toList(),
              allOptions: widget.availableFilters.statuses.values.toList(),
              onChanged: (displayNames) {
                final selectedKeys = <String>[];
                for (final displayName in displayNames) {
                  final key = widget.availableFilters.statuses.entries
                      .firstWhere((entry) => entry.value == displayName,
                          orElse: () => const MapEntry('', ''))
                      .key;
                  if (key.isNotEmpty) {
                    selectedKeys.add(key);
                  }
                }
                setState(() {
                  _pendingFilters = _pendingFilters.copyWith(statuses: {
                    for (final key in selectedKeys)
                      key: widget.availableFilters.statuses[key] ?? key
                  });
                });
              },
            ),
            // Озвучка
            _buildMultiSelectDropdown(
              hint: 'Озвучка',
              selectedValues: _pendingFilters.voices.values.toList(),
              allOptions: widget.availableFilters.voices.values.toList(),
              onChanged: (displayNames) {
                final selectedKeys = <String>[];
                for (final displayName in displayNames) {
                  final key = widget.availableFilters.voices.entries
                      .firstWhere((entry) => entry.value == displayName,
                          orElse: () => const MapEntry('', ''))
                      .key;
                  if (key.isNotEmpty) {
                    selectedKeys.add(key);
                  }
                }
                setState(() {
                  _pendingFilters = _pendingFilters.copyWith(voices: {
                    for (final key in selectedKeys)
                      key: widget.availableFilters.voices[key] ?? key
                  });
                });
              },
            ),
            // Лицензиатор
            _buildMultiSelectDropdown(
              hint: 'Лицензиатор',
              selectedValues: _pendingFilters.licensors.values.toList(),
              allOptions: widget.availableFilters.licensors.values.toList(),
              onChanged: (displayNames) {
                final selectedKeys = <String>[];
                for (final displayName in displayNames) {
                  final key = widget.availableFilters.licensors.entries
                      .firstWhere((entry) => entry.value == displayName,
                          orElse: () => const MapEntry('', ''))
                      .key;
                  if (key.isNotEmpty) {
                    selectedKeys.add(key);
                  }
                }
                setState(() {
                  _pendingFilters = _pendingFilters.copyWith(licensors: {
                    for (final key in selectedKeys)
                      key: widget.availableFilters.licensors[key] ?? key
                  });
                });
              },
            ),
            // Сортировка (single select)
            _buildDropdownFilter(
              hint: 'Сортировка',
              value: _pendingFilters.sortBy.isNotEmpty ? _pendingFilters.sortBy : null,
              items: const [
                DropdownMenuItem(value: 'news_read', child: Text('По новизне')),
                DropdownMenuItem(value: 'title', child: Text('По названию')),
                DropdownMenuItem(value: 'year', child: Text('По году')),
                DropdownMenuItem(value: 'rating', child: Text('По рейтингу')),
              ],
              onChanged: (value) {
                setState(() {
                  _pendingFilters = _pendingFilters.copyWith(sortBy: value ?? '');
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Год (Range Slider)
        _buildRangeSliderFilter(
          label: 'Год',
          min: 1980,
          max: 2025,
          values: RangeValues(
            _pendingFilters.yearFrom?.toDouble() ?? 1980,
            _pendingFilters.yearTo?.toDouble() ?? 2025,
          ),
          onChanged: (values) {
            setState(() {
              _pendingFilters = _pendingFilters.copyWith(
                yearFrom: values.start.round(),
                yearTo: values.end.round(),
              );
            });
          },
        ),
        // Рейтинг (Range Slider)
        _buildRangeSliderFilter(
          label: 'Рейтинг',
          min: 0,
          max: 10,
          values: RangeValues(
            _pendingFilters.ratingFrom ?? 0,
            _pendingFilters.ratingTo ?? 10,
          ),
          onChanged: (values) {
            setState(() {
              _pendingFilters = _pendingFilters.copyWith(
                ratingFrom: values.start,
                ratingTo: values.end,
              );
            });
          },
        ),
        const SizedBox(height: 16),
        // Кнопки управления фильтрами
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _pendingFilters = SeriesFilters.empty();
                });
              },
              child: const Text('Сбросить'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                widget.onFiltersChanged(_pendingFilters);
                widget.onApplyFilters();
              },
              child: const Text('Применить'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileDropdownFilter({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Add category-specific "reset" option at the beginning
    final allItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(hint, overflow: TextOverflow.ellipsis),
      ),
      ...items,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<String>(
          key: ValueKey('${hint}_$value'), // Unique key for rebuild
          initialSelection: value,
          dropdownMenuEntries: allItems.where((item) => item.value != null).map((item) =>
            DropdownMenuEntry<String>(
              value: item.value!,
              label: item.child is Text ? (item.child as Text).data! : hint,
            )
          ).toList(),
          onSelected: onChanged,
          hintText: hint,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMobileMultiSelectDropdown({
    required String hint,
    required List<String> selectedValues,
    required List<String> allOptions,
    required ValueChanged<List<String>> onChanged,
  }) {
    final displayText = selectedValues.isEmpty
        ? hint
        : selectedValues.length == 1
            ? selectedValues.first
            : '${selectedValues.length} выбрано';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiSelectDropdownButton(
          hint: hint,
          displayText: displayText,
          selectedValues: selectedValues,
          allOptions: allOptions,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMobileRangeSliderFilter({
    required String label,
    required double min,
    required double max,
    required RangeValues values,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBodyMedium('$label: ${values.start.round()} - ${values.end.round()}'),
        const SizedBox(height: 8),
        RangeSlider(
          min: min,
          max: max,
          values: values,
          onChanged: onChanged,
          divisions: (max - min).round(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showMobileFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppH3('Фильтры'),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Тип контента - multi-select
              _buildMobileMultiSelectDropdown(
                hint: 'Тип',
                selectedValues: _pendingFilters.types.values.toList(),
                allOptions: widget.availableFilters.types.values.toList(),
                onChanged: (displayNames) {
                  final selectedKeys = <String>[];
                  for (final displayName in displayNames) {
                    final key = widget.availableFilters.types.entries
                        .firstWhere((entry) => entry.value == displayName,
                            orElse: () => const MapEntry('', ''))
                        .key;
                    if (key.isNotEmpty) {
                      selectedKeys.add(key);
                    }
                  }
                  setState(() {
                    _pendingFilters = _pendingFilters.copyWith(types: {
                      for (final key in selectedKeys)
                        key: widget.availableFilters.types[key] ?? key
                    });
                  });
                },
              ),
              // Жанры - multi-select
              _buildMobileMultiSelectDropdown(
                hint: 'Жанр',
                selectedValues: _pendingFilters.genres.values.toList(),
                allOptions: widget.availableFilters.genres.values.toList(),
                onChanged: (displayNames) {
                  final selectedKeys = <String>[];
                  for (final displayName in displayNames) {
                    final key = widget.availableFilters.genres.entries
                        .firstWhere((entry) => entry.value == displayName,
                            orElse: () => const MapEntry('', ''))
                        .key;
                    if (key.isNotEmpty) {
                      selectedKeys.add(key);
                    }
                  }
                  setState(() {
                    _pendingFilters = _pendingFilters.copyWith(genres: {
                      for (final key in selectedKeys)
                        key: widget.availableFilters.genres[key] ?? key
                    });
                  });
                },
              ),
              // Статус - multi-select
              _buildMobileMultiSelectDropdown(
                hint: 'Статус',
                selectedValues: _pendingFilters.statuses.values.toList(),
                allOptions: widget.availableFilters.statuses.values.toList(),
                onChanged: (displayNames) {
                  final selectedKeys = <String>[];
                  for (final displayName in displayNames) {
                    final key = widget.availableFilters.statuses.entries
                        .firstWhere((entry) => entry.value == displayName,
                            orElse: () => const MapEntry('', ''))
                        .key;
                    if (key.isNotEmpty) {
                      selectedKeys.add(key);
                    }
                  }
                  setState(() {
                    _pendingFilters = _pendingFilters.copyWith(statuses: {
                      for (final key in selectedKeys)
                        key: widget.availableFilters.statuses[key] ?? key
                    });
                  });
                },
              ),
              // Озвучка - multi-select
              _buildMobileMultiSelectDropdown(
                hint: 'Озвучка',
                selectedValues: _pendingFilters.voices.values.toList(),
                allOptions: widget.availableFilters.voices.values.toList(),
                onChanged: (displayNames) {
                  final selectedKeys = <String>[];
                  for (final displayName in displayNames) {
                    final key = widget.availableFilters.voices.entries
                        .firstWhere((entry) => entry.value == displayName,
                            orElse: () => const MapEntry('', ''))
                        .key;
                    if (key.isNotEmpty) {
                      selectedKeys.add(key);
                    }
                  }
                  setState(() {
                    _pendingFilters = _pendingFilters.copyWith(voices: {
                      for (final key in selectedKeys)
                        key: widget.availableFilters.voices[key] ?? key
                    });
                  });
                },
              ),
              // Лицензиатор - multi-select
              _buildMobileMultiSelectDropdown(
                hint: 'Лицензиатор',
                selectedValues: _pendingFilters.licensors.values.toList(),
                allOptions: widget.availableFilters.licensors.values.toList(),
                onChanged: (displayNames) {
                  final selectedKeys = <String>[];
                  for (final displayName in displayNames) {
                    final key = widget.availableFilters.licensors.entries
                        .firstWhere((entry) => entry.value == displayName,
                            orElse: () => const MapEntry('', ''))
                        .key;
                    if (key.isNotEmpty) {
                      selectedKeys.add(key);
                    }
                  }
                  setState(() {
                    _pendingFilters = _pendingFilters.copyWith(licensors: {
                      for (final key in selectedKeys)
                        key: widget.availableFilters.licensors[key] ?? key
                    });
                  });
                },
              ),
              // Сортировка
              _buildMobileDropdownFilter(
                hint: 'Сортировка',
                value: _pendingFilters.sortBy.isNotEmpty ? _pendingFilters.sortBy : null,
                items: const [
                  DropdownMenuItem(value: 'news_read', child: Text('По новизне')),
                  DropdownMenuItem(value: 'title', child: Text('По названию')),
                  DropdownMenuItem(value: 'year', child: Text('По году')),
                  DropdownMenuItem(value: 'rating', child: Text('По рейтингу')),
                ],
                onChanged: (value) {
                  setState(() {
                    _pendingFilters = _pendingFilters.copyWith(sortBy: value ?? '');
                  });
                },
              ),
              const SizedBox(height: 16),
              // Год (Range Slider)
              _buildMobileRangeSliderFilter(
                label: 'Год',
                min: 1980,
                max: 2025,
                values: RangeValues(
                  _pendingFilters.yearFrom?.toDouble() ?? 1980,
                  _pendingFilters.yearTo?.toDouble() ?? 2025,
                ),
                onChanged: (values) {
                  setState(() {
                    _pendingFilters = _pendingFilters.copyWith(
                      yearFrom: values.start.round(),
                      yearTo: values.end.round(),
                    );
                  });
                },
              ),
              // Рейтинг (Range Slider)
              _buildMobileRangeSliderFilter(
                label: 'Рейтинг',
                min: 0,
                max: 10,
                values: RangeValues(
                  _pendingFilters.ratingFrom ?? 0,
                  _pendingFilters.ratingTo ?? 10,
                ),
                onChanged: (values) {
                  setState(() {
                    _pendingFilters = _pendingFilters.copyWith(
                      ratingFrom: values.start,
                      ratingTo: values.end,
                    );
                  });
                },
              ),
              const SizedBox(height: 24),
              // Кнопки управления
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _pendingFilters = SeriesFilters.empty();
                        });
                        Navigator.of(context).pop();
                        widget.onFiltersChanged(_pendingFilters);
                        widget.onResetFilters();
                      },
                      child: const Text('Сбросить'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onFiltersChanged(_pendingFilters);
                        widget.onApplyFilters();
                      },
                      child: const Text('Применить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        // Компактная версия фильтров для мобильного - кнопка открытия модального окна
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showMobileFiltersDialog,
            icon: const Icon(Icons.filter_list),
            label: const Text('Фильтры'),
          ),
        ),
        const SizedBox(height: 8),
        // Кнопки сброса и применения
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _pendingFilters = SeriesFilters.empty();
                  });
                  widget.onFiltersChanged(_pendingFilters);
                  widget.onResetFilters();
                },
                child: const Text('Сбросить'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  widget.onFiltersChanged(_pendingFilters);
                  widget.onApplyFilters();
                },
                child: const Text('Применить'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isExpanded = !isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: AppH3('Фильтры'),
              );
            },
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.isDesktop
                  ? _buildDesktopFilters()
                  : _buildMobileFilters(),
            ),
            isExpanded: _isExpanded,
          ),
        ],
      ),
    );
  }
}
