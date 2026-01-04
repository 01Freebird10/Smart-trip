import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  String _activePolicyTitle = "Privacy Policy";
  String _activePolicyContent = "";

  void _showPolicy(String title, String content) {
    setState(() {
      _activePolicyTitle = title;
      _activePolicyContent = content;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) return;
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri)) return;
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) return;
  }

  void _showFeedbackDialog() {
    final emailController = TextEditingController(text: "info@remoteward.com");
    final userEmailController = TextEditingController();
    final feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
        title: Text("Send Feedback", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              readOnly: true,
              style: const TextStyle(color: Colors.white70),
              decoration: InputDecoration(
                labelText: "To",
                labelStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: userEmailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Your Email",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Your thoughts...",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feedback sent! Thank you.")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0091EA)),
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildPolicyDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black,
              Color(0xFF0091EA),
            ],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Header/Nav
              _buildNavBar(context),
              
              // Hero Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? size.width * 0.1 : 24,
                  vertical: 60,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Smart Trip\nPlanner',
                              style: GoogleFonts.outfit(
                                fontSize: isDesktop ? 80 : 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'The ultimate platform to plan, collaborate, and share your adventures with friends in real-time.',
                              style: TextStyle(
                                fontSize: isDesktop ? 20 : 18,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 48),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/login'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 26),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    backgroundColor: Colors.white,
                                    foregroundColor: theme.colorScheme.primary,
                                    elevation: 5,
                                  ),
                                  child: const Text('Start Planning Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isDesktop)
                      Expanded(
                        flex: 4,
                        child: _buildHeroImage(),
                      ),
                  ],
                ),
              ),
              
              // Features section
              Container(key: _featuresKey),
              _buildFeatures(context),

              // About Section
              Container(key: _aboutKey),
              _buildAbout(context),
              
              // Footer
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(60, 100, 60, 40),
      color: Colors.black.withOpacity(0.95),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Text('SmartTrip', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Contact', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _contactRow(Icons.email_outlined, 'info@remoteward.com', () => _sendEmail('info@remoteward.com')),
                        const SizedBox(height: 12),
                        _contactRow(Icons.phone_outlined, '+91-9997095098', () => _makePhoneCall('+919997095098')),
                        const SizedBox(height: 12),
                        _contactRow(
                          Icons.location_on_outlined, 
                          'Regd. Office: Yenepoya (Deemed to be University) Deralakatte, Mangalore, Dakshina Kannada, Karnataka – 575018', 
                          () => _launchURL("https://www.google.com/maps/search/?api=1&query=Yenepoya+University+Deralakatte")
                        ),
                        const SizedBox(height: 12),
                        _contactRow(Icons.language_outlined, 'remoteward.com', () => _launchURL('https://remoteward.com')),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildFooterColumn('Company', [
                _footerLink('About Us', () => _scrollToSection(_aboutKey)),
                _footerLink('Features', () => _scrollToSection(_featuresKey)),
              ]),
              const SizedBox(width: 60),
              _buildFooterColumn('Support', [
                _footerLink('Privacy Policy', () => _showPolicy('Privacy Policy', _privacyPolicyContent)),
                _footerLink('Terms of Service', () => _showPolicy('Terms of Service', _termsOfServiceContent)),
                _footerLink('Feedback', () => _showFeedbackDialog()),
                _footerLink('Help Center', () => _showPolicy('Help Center', _helpCenterContent)),
              ]),
            ],
          ),
          const SizedBox(height: 60),
          const Divider(color: Colors.white10),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 SmartTrip Planner. All rights reserved. Made for Adventure.',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
              ),
              Row(
                children: [
                  _socialIcon(FontAwesomeIcons.linkedinIn, "https://www.linkedin.com/company/remoteward/"),
                  _socialIcon(FontAwesomeIcons.instagram, "https://www.instagram.com/remoteward/"),
                  _socialIcon(FontAwesomeIcons.xTwitter, "https://twitter.com/remoteward"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(onTap == null ? 0.3 : 0.6),
          fontSize: 14,
          fontWeight: onTap == null ? FontWeight.normal : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPolicyDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * (MediaQuery.of(context).size.width > 900 ? 0.3 : 0.8),
      backgroundColor: const Color(0xFF0A0A0A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activePolicyTitle,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Text(
                  _activePolicyContent,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.8, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const String _privacyPolicyContent = """
Privacy Policy

At SmartTrip Planner, we take your privacy seriously. This policy describes how we collect, use, and handle your data.

1. Information We Collect
We collect information you provide directly to us (e.g., name, email, trip details) and information generated through your use of the app.

2. How We Use Information
We use your information to provide, maintain, and improve our services, including personalized trip recommendations and collaboration features.

3. Sharing of Information
We do not share your personal information with third parties except as necessary to provide our services or as required by law.

4. Your Rights
You have the right to access, update, or delete your personal information at any time.
  """;

  static const String _termsOfServiceContent = """
Terms of Service

By using SmartTrip Planner, you agree to these terms. Please read them carefully.

1. Use of Services
You must follow any policies made available to you within the Services. Don’t misuse our Services.

2. Your Account
You may need a SmartTrip account to use some of our Services. You are responsible for the activity that happens on or through your account.

3. Content in Our Services
Our Services display some content that is not SmartTrip’s. This content is the sole responsibility of the entity that makes it available.

4. Liability for Our Services
To the extent permitted by law, SmartTrip will not be responsible for lost profits, revenues, or data.
  """;

  static const String _helpCenterContent = """
Help Center

Welcome to the SmartTrip Help Center. How can we help you plan your next adventure?

1. Getting Started
Learn how to create your first trip, invite friends, and start adding destinations.

2. Managing Trips
Everything you need to know about editing itineraries, setting budgets, and tracking expenses.

3. Collaborating
Tips on how to effectively plan with friends, use polls to make decisions, and chat in real-time.

4. Account & Settings
Manage your profile, change your password, and customize your app experience.

5. Troubleshooting
Common issues and their solutions. If you can't find what you're looking for, contact us at info@remoteward.com.
  """;

  Widget _buildFooterColumn(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 20),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: item,
        )),
      ],
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: IconButton(
        onPressed: () => _launchURL(url),
        icon: FaIcon(icon, color: Colors.white.withOpacity(0.4), size: 20),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 20,
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Row(
        children: [
          const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Text(
            'SmartTrip',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (MediaQuery.of(context).size.width > 600) ...[
            _navItem(context, 'Features', onTap: () => _scrollToSection(_featuresKey)),
            _navItem(context, 'About', onTap: () => _scrollToSection(_aboutKey)),
            const SizedBox(width: 20),
          ],
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String title, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.map_rounded, size: 240, color: Colors.white),
          SizedBox(height: 20),
          Text('Visualize Your Journey', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildAbout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.white.withOpacity(0.02),
      child: Column(
        children: [
          const Text(
            'Our Story',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 800,
            child: Text(
              'SmartTrip Planner was born from a passion for exploration and a frustration with messy group chats and spread-out plans. We believe that planning a journey should be as exciting as the trip itself. Our mission is to provide the world\'s most seamless, interactive, and collaborative travel planning experience.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.7), height: 1.6),
            ),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _aboutStat('10K+', 'Active Travelers'),
              _aboutStat('50K+', 'Trips Planned'),
              _aboutStat('150+', 'Countries Covered'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aboutStat(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Column(
        children: [
          const Text(
            'Built for Travelers',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _featureCard(Icons.group_add_rounded, 'Seamless Collaboration', 'Invite your friends and plan together in one unified workspace with instant sync.'),
              _featureCard(Icons.map_rounded, 'Visual Itinerary', 'See your entire journey mapped out beautifully with optimized routes and local insights.'),
              _featureCard(Icons.lightbulb_outline_rounded, 'Smart Recommendations', 'Get personalized suggestions for hidden gems, local eatries, and seasonal events.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 48),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
