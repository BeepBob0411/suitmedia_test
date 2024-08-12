import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ThirdScreen extends StatefulWidget {
  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  List users = [];
  int currentPage = 1;
  bool isLoading = false;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      setState(() {
        currentPage = 1;
        isLastPage = false;
        users.clear();
      });
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://reqres.in/api/users?page=$currentPage&per_page=10'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        users.addAll(data['data']);
        isLastPage = data['data'].length < 10;
        currentPage++;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load users');
    }
  }

  Future<void> _refresh() async {
    await fetchUsers(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Third Screen'),
      ),
      body: users.isEmpty
          ? Center(child: Text('No users found'))
          : RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: users.length + (isLastPage ? 0 : 1),
          itemBuilder: (context, index) {
            if (index == users.length) {
              fetchUsers();
              return Center(child: CircularProgressIndicator());
            }

            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['avatar']),
              ),
              title: Text('${user['first_name']} ${user['last_name']}'),
              subtitle: Text(user['email']),
              onTap: () {
                Navigator.pop(context,
                    '${user['first_name']} ${user['last_name']}');
              },
            );
          },
        ),
      ),
    );
  }
}
