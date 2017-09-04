import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './homeScreen.dart' as homeScreeen;
import './bookmarksScreen.dart' as bookmarkScreen;

void main() {
	runApp(new MaterialApp(
		home: new NewsApp()
	));
}

class  NewsApp extends StatefulWidget {
	@override
	 createState() => new NewsAppState();
}

class NewsAppState extends State<NewsApp> with SingleTickerProviderStateMixin {
	TabController controller;
	final googleSignIn = new GoogleSignIn();
	final analytics = new FirebaseAnalytics();
	final auth = FirebaseAuth.instance;

	Future<Null> _ensureLoggedIn() async {
		GoogleSignInAccount user = googleSignIn.currentUser;
		if (user == null)
			user = await googleSignIn.signInSilently();
		if (user == null) {
			await googleSignIn.signIn();
			analytics.logLogin();
		}
		if (await auth.currentUser() == null) {
			GoogleSignInAuthentication credentials =
			await googleSignIn.currentUser.authentication;
			await auth.signInWithGoogle(
				idToken: credentials.idToken,
				accessToken: credentials.accessToken,
			);
		}
	}
	@override
	void initState() {
		super.initState();
		controller = new TabController(vsync: this, length: 2);
		_ensureLoggedIn();
	}

	@override
	void dispose() {
		controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
			appBar: new AppBar(
				title: new Text("News App"),
			),
			bottomNavigationBar: new Material(
				color: Colors.blue[600],
				child: new TabBar(
					controller: controller,
					tabs: <Tab>[
						new Tab(icon: new Icon(Icons.home), text: "For You"),
						new Tab(icon: new Icon(Icons.bookmark), text: "Read Later"),
					]
				)
			),
			body: new TabBarView(
				controller: controller,
				children: <Widget>[
					new homeScreeen.HomeScreen(),
					new bookmarkScreen.BookmarksScreen()
				]
			)
		);
	}
}