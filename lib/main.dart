import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class GithubSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub Repository Search',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GithubSearchPage(),
    );
  }
}

class GithubSearchPage extends StatefulWidget {
  @override
  _GithubSearchPageState createState() => _GithubSearchPageState();
}

class _GithubSearchPageState extends State<GithubSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _repos = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _searchRepos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.github.com/search/repositories?q=${_controller.text}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _repos = data['items'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load repositories');
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred while fetching repositories';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('GitHub Repository Search'),
        backgroundColor: Colors.greenAccent,
        elevation: 1,
        shadowColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter repository name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchRepos,
                  child: Text(_isLoading ? 'Searching...' : 'Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: ListView.builder(
                itemCount: _repos.length,
                itemBuilder: (context, index) {
                  final repo = _repos[index];
                  return Card(
                    color: Colors.amberAccent,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  repo['name'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(repo['full_name'])
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(repo['description'].toString().length > 100
                              ? repo['description'].toString().substring(0, 100)
                              : repo['description'] ?? 'No description'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16),
                              const SizedBox(width: 4),
                              Text('${repo['stargazers_count']}'),
                              const SizedBox(width: 16),
                              const Icon(Icons.call_split, size: 16),
                              const SizedBox(width: 4),
                              Text('${repo['forks_count']}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(repo['html_url']);
                              if (await canLaunchUrl(uri)) {
                                launchUrl(uri);
                              }
                            },
                            child: const Text(
                              'View on GitHub',
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(GithubSearchApp());
