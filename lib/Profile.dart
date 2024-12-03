import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool mailNotifications = true;
  bool smsNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Information Section
              Text(
                'User Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.person, size: 40),
                title: Text('John Doe'),
                subtitle: Text('johndoe@example.com'),
              ),
              Divider(),

              // Notification Settings
              Text(
                'Notification Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: Text('Receive Email Notifications'),
                value: mailNotifications,
                onChanged: (bool value) {
                  setState(() {
                    mailNotifications = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Receive SMS Notifications'),
                value: smsNotifications,
                onChanged: (bool value) {

                  smsNotifications = value;
                  setState(() {});
                },
              ),
              Divider(),
              Text(
                'My Events & Gifts',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.event),
                title: Text('Birthday Party'),
                subtitle: Text('Gifts: Toy Car, Book'),
                onTap: () {
                  // Navigate to event details
                },
              ),
              ListTile(
                leading: Icon(Icons.event),
                title: Text('Wedding Anniversary'),
                subtitle: Text('Gifts: Watch, Perfume'),
                onTap: () {
                  // Navigate to event details
                },
              ),
              Divider(),

              // Link to My Pledged Gifts Page
              ListTile(
                leading: Icon(Icons.card_giftcard),
                title: Text('My Pledged Gifts'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to My Pledged Gifts Page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



