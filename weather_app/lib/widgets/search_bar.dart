import 'package:flutter/material.dart';

class SearchCityBar extends StatefulWidget {
  final Function(String) onSearch;
  const SearchCityBar({super.key, required this.onSearch});

  @override
  State<SearchCityBar> createState() => _SearchCityBarState();
}

class _SearchCityBarState extends State<SearchCityBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Enter city name",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              widget.onSearch(_controller.text);
            },
          )
        ],
      ),
    );
  }
}
