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

  void _onCategorySelected(String categoryKey, String label) {
    _controller.text = label;
    _onQueryChanged(categoryKey);
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
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  onChanged: _onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search offline location or AI command...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                    prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _controller.clear();
                              _onQueryChanged('');
                            },
                          )
                        : const Icon(Icons.mic, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
                if (_isSearching) const LinearProgressIndicator(minHeight: 2),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Quick Category Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('search_gas_station', '⛽ Gas Stations', Colors.orange),
              const SizedBox(width: 8),
              _buildCategoryChip('search_hospital', '🏥 Hospitals', Colors.red),
              const SizedBox(width: 8),
              _buildCategoryChip('search_food', '☕ Food & Cafe', Colors.brown),
              const SizedBox(width: 8),
              _buildCategoryChip('atm', '🏦 ATMs', Colors.green),
            ],
          ),
        ),
        if (_detectedIntent != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
                label: Text('AI Intent: ${_detectedIntent!}'),
                backgroundColor: Colors.blue.shade50,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (_searchResults.isNotEmpty)
          Card(
            elevation: 6,
            margin: const EdgeInsets.only(top: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final poi = _searchResults[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, color: Colors.red, size: 20),
                    ),
                    title: Text(
                      poi['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Lat: ${(poi['latitude'] as num).toStringAsFixed(3)}, Lon: ${(poi['longitude'] as num).toStringAsFixed(3)}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onTap: () => _selectResult(poi),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(String key, String label, Color color) {
    return ActionChip(
      avatar: Text(label.split(' ')[0], style: const TextStyle(fontSize: 14)),
      label: Text(label.substring(2), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      backgroundColor: Colors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _onCategorySelected(key, label.substring(2)),
    );
  }
}
