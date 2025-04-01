import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For better typography
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key, required this.isFromSettings}) : super(key: key);

  final bool isFromSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Epsilon Diary"),
        leading: isFromSettings
            ? null
            : IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
                },
              ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 20),
            _buildStatisticsSection(),
            const SizedBox(height: 20),
            _buildIntroductionSection(),
            const SizedBox(height: 20),
            _buildKeyFeaturesSection(),
            const SizedBox(height: 20),
            _buildWhoBenefitsSection(),
            const SizedBox(height: 20),
            _buildLinksSection(),
            const SizedBox(height: 20),
            _buildFooterSection(),
          ],
        ),
      ),
    );
  }

  /// 🔹 Header Section
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0175C2),
            Color(0xFF004A77),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Image.asset(
              "assets/images/EISlogo.png", // Replace with your logo asset
              height: 180, width: 180,
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                "Epsilon Diary",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                "Smart School Management - Simplified",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Impactful Statistics Section
  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildStatCard("🏫 50+ Schools", "Trusted by leading institutions"),
          _buildStatCard("👨‍🏫 2,000+ Teachers & Admins", "Enhancing education management"),
          _buildStatCard("👩‍🎓 50,000+ Students", "Simplifying student progress tracking"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String subtitle) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.school, color: Colors.blueAccent, size: 30),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
      ),
    );
  }

  /// 🔹 Introduction Section
  Widget _buildIntroductionSection() {
    return _buildTextSection(
      title: "What is Epsilon Diary?",
      content:
          "Epsilon Diary is a comprehensive school management system that simplifies administrative tasks, enhances communication, and boosts efficiency for schools. Whether you're an administrator, teacher, or parent, Epsilon Diary keeps everyone connected seamlessly with its cloud-based, mobile-friendly platform.",
    );
  }

  /// 🔹 Key Features Section
  Widget _buildKeyFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Key Features",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          _buildFeatureTile("📌 Attendance & Digital Records", "Automate attendance tracking and maintain accurate student records."),
          _buildFeatureTile("📊 Exam & Performance Tracking", "Schedule exams, generate reports, and analyze student progress."),
          _buildFeatureTile("💰 Seamless Fee Management", "Track fee payments, generate invoices, and manage finances efficiently."),
          _buildFeatureTile("📖 Smart Digital Diary", "Share assignments, homework, and important updates with students and parents."),
          _buildFeatureTile("📢 Notice Board & Communication", "Enable real-time announcements and direct messaging."),
          _buildFeatureTile("🔍 Data-Driven Insights", "Generate detailed reports to help administrators make informed decisions."),
        ],
      ),
    );
  }

  /// 🔹 Who Benefits Section
  Widget _buildWhoBenefitsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Who Benefits from Epsilon Diary?",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          _buildFeatureTile(
              "🏫 School Administrators", "Streamline school operations, manage finances, and gain insights for better decision-making."),
          _buildFeatureTile("👨‍🏫 Teachers", "Easily manage attendance, exams, assignments, and communication with students and parents."),
          _buildFeatureTile(
              "👨‍👩‍👧‍👦 Parents & Students", "Stay informed about assignments, performance, and important school updates in real-time."),
        ],
      ),
    );
  }

  /// 🔹 Links Section
  Widget _buildLinksSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Explore More",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          _buildLinkCard(
            const Icon(Icons.book, color: Colors.blueAccent),
            "Learn More",
            "Discover what Epsilon Diary can do",
            "https://linktr.ee/epsilondiary",
          ),
          _buildLinkCard(
            const Icon(Icons.video_library, color: Colors.redAccent),
            "Watch Explainer Video",
            "See Epsilon Diary in action",
            "https://www.youtube.com/watch?v=ySchrZKZO1w&t=2s",
          ),
          _buildLinkCard(
            const Icon(Icons.dialpad_outlined),
            "Contact Us",
            "Call us directly",
            "tel://+918985226644",
          ),
          _buildLinkCard(
            const Icon(Icons.whatsapp, color: Colors.green,),
            "WhatsApp",
            "Chat with us on WhatsApp",
            "https://api.whatsapp.com/send/?phone=%2B918985228844&text&type=phone_number",
          ),
          _buildLinkCard(
            const Icon(Icons.download, color: Colors.cyan,),
            "Install",
            "Install Epsilon Diary on your device",
            "https://epsilondiary.web.app/install",
          ),
        ],
      ),
    );
  }

  /// 🔹 Footer Section
  Widget _buildFooterSection() {
    return _buildTextSection(
      title: "Get in Touch",
      content: "Have questions or need assistance? Reach out to us!\n\n📧 Email:\nepsiloninfinityservices@gmail.com\n📞 Phone:\n+91 8985 22 66 44",
    );
  }

  /// 🔹 Helper Methods

  Widget _buildFeatureTile(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.blueAccent),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildLinkCard(Icon icon, String title, String subtitle, String url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: icon,
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward, color: Colors.blueAccent),
        onTap: () async {
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw "Could not launch $url";
          }
        },
      ),
    );
  }

  Widget _buildTextSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 10),
          Text(content, style: GoogleFonts.poppins(fontSize: 16)),
        ],
      ),
    );
  }
}
