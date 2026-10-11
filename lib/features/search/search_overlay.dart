import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/ai/ai_intent_engine.dart';
import '../../core/storage/database_manager.dart';

class SearchOverlay extends StatefulWidget {
  final Function(LatLng location, String name) onSearchResultSelected;

  const SearchOverlay({
    super.key,
    required this.onSearchResultSelected,
  });

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _controller = TextEditingController();
  final DatabaseManager _dbManager = DatabaseManager();
  final AiIntentEngine _aiEngine = AiIntentEngine();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _detectedIntent;

  void _onQueryChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _detectedIntent = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final intent = await _aiEngine.detectIntent(query);
    String filterQuery = query;

    if (intent == 'search_gas_station') {
      filterQuery = 'gas_station';
    } else if (intent == 'search_hospital') {
      filterQuery = 'hospital';
    } else if (intent == 'search_food') {
      filterQuery = 'cafe';
    }

    final results = await _dbManager.searchPois(filterQuery);

    if (mounted) {
      setState(() {
        _searchResults = results;
        _detectedIntent = intent;
        _isSearching = false;
      });
    }
  }

  void _selectResult(Map<String, dynamic> poi) {
    final lat = (poi['latitude'] as num).toDouble();
    final lng = (poi['longitude'] as num).toDouble();
    final name = poi['name'] as String;

    widget.onSearchResultSelected(LatLng(lat, lng), name);

    _controller.clear();
    setState(() {
      _searchResults = [];
      _detectedIntent = null;
    });

    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  onChanged: _onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search offline destination or AI command...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              _onQueryChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                ),
                if (_isSearching) const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
        if (_detectedIntent != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.auto_awesome, size: 16),
                label: Text('AI Intent: ${_detectedIntent!}'),
                backgroundColor: Colors.blue.shade50,
              ),
            ),
          ),
        if (_searchResults.isNotEmpty)
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(top: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final poi = _searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(poi['name'] as String),
                  subtitle: Text(
                      '${(poi['latitude'] as num).toStringAsFixed(4)}, ${(poi['longitude'] as num).toStringAsFixed(4)}'),
                  onTap: () => _selectResult(poi),
                );
              },
            ),
          ),
      ],
    );
  }
}
