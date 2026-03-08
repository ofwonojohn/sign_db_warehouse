import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'upload_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 260,
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Column(
                    children: [
                      Icon(Icons.sign_language, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        "Sign Warehouse",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Uganda Data Platform",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      _navItem(0, Icons.dashboard, "Dashboard"),
                      _navItem(1, Icons.analytics, "Model Performance"),
                      _navItem(2, Icons.pie_chart, "Dataset Coverage"),
                      _navItem(3, Icons.speed, "Real-time Monitoring"),
                      _navItem(4, Icons.map, "School Map"),
                      _navItem(5, Icons.cloud_upload, "Upload Videos"),
                    ],
                  ),
                ),
                // Logout
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ApiService.logout();
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getTitle(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      if (ApiService.schoolName != null)
                        Chip(
                          avatar: const CircleAvatar(
                            backgroundColor: Color(0xFF1E88E5),
                            child: Icon(Icons.school, color: Colors.white, size: 16),
                          ),
                          label: Text(ApiService.schoolName!),
                          backgroundColor: const Color(0xFFE3F2FD),
                        ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Executive Overview";
      case 1:
        return "Model Performance";
      case 2:
        return "Dataset Coverage";
      case 3:
        return "Real-time Monitoring";
      case 4:
        return "School Map";
      case 5:
        return "Upload Videos";
      default:
        return "Dashboard";
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardOverview();
      case 1:
        return const ModelPerformanceScreen();
      case 2:
        return const DatasetCoverageScreen();
      case 3:
        return const RealTimeMonitoringScreen();
      case 4:
        return const SchoolMapScreen();
      case 5:
        return const UploadScreen();
      default:
        return const DashboardOverview();
    }
  }
}

// ========================
// DASHBOARD OVERVIEW
// ========================

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  Map<String, dynamic>? summary;
  List<dynamic> regionData = [];
  List<dynamic> schoolData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final summaryData = await ApiService.getDashboardSummary();
      final region = await ApiService.getVideosPerRegion();
      final schools = await ApiService.getVideosPerSchool();
      
      if (mounted) {
        setState(() {
          summary = summaryData;
          regionData = region;
          schoolData = schools;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _summaryCard(
                "Total Videos",
                "${summary?['total_videos'] ?? 0}",
                Icons.video_library,
                const Color(0xFF1E88E5),
              ),
              _summaryCard(
                "Participating Schools",
                "${summary?['total_schools'] ?? 0}",
                Icons.school,
                const Color(0xFF43A047),
              ),
              _summaryCard(
                "Videos Today",
                "${summary?['videos_today'] ?? 0}",
                Icons.today,
                const Color(0xFFFF9800),
              ),
              _summaryCard(
                "Top School",
                summary?['top_school']?['name'] ?? "N/A",
                Icons.emoji_events,
                const Color(0xFF9C27B0),
                subtitle: "${summary?['top_school']?['count'] ?? 0} videos",
              ),
              _summaryCard(
                "Sign Categories",
                "${summary?['total_categories'] ?? 0}",
                Icons.category,
                const Color(0xFF00BCD4),
              ),
              _summaryCard(
                "Total Signs",
                "${summary?['total_signs'] ?? 0}",
                Icons.sign_language,
                const Color(0xFFE91E63),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Data Tables Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Videos Per Region
              Expanded(
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Videos Per Region",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (regionData.isEmpty)
                          const Text("No data available")
                        else
                          DataTable(
                            columns: const [
                              DataColumn(label: Text("Region")),
                              DataColumn(label: Text("Videos"), numeric: true),
                            ],
                            rows: regionData.map<DataRow>((r) => DataRow(cells: [
                              DataCell(Text(r['region'] ?? '')),
                              DataCell(Text("${r['count'] ?? 0}")),
                            ])).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Top Contributing Schools
              Expanded(
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Top Contributing Schools",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (schoolData.isEmpty)
                          const Text("No data available")
                        else
                          DataTable(
                            columns: const [
                              DataColumn(label: Text("School")),
                              DataColumn(label: Text("Videos"), numeric: true),
                            ],
                            rows: schoolData.take(10).map<DataRow>((s) => DataRow(cells: [
                              DataCell(Text(s['school_name'] ?? '')),
                              DataCell(Text("${s['video_count'] ?? 0}")),
                            ])).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Latency & FPS Placeholder Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.speed, size: 40, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text(
                          "Average Latency",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Pending Implementation",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        Chip(
                          label: const Text("Coming Soon"),
                          backgroundColor: Colors.orange[100],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.videocam, size: 40, color: Colors.grey),
                        const SizedBox(height: 10),
                        const Text(
                          "Average FPS",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Pending Implementation",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        Chip(
                          label: const Text("Coming Soon"),
                          backgroundColor: Colors.orange[100],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ========================
// MODEL PERFORMANCE
// ========================

class ModelPerformanceScreen extends StatefulWidget {
  const ModelPerformanceScreen({super.key});

  @override
  State<ModelPerformanceScreen> createState() => _ModelPerformanceScreenState();
}

class _ModelPerformanceScreenState extends State<ModelPerformanceScreen> {
  List<dynamic> models = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.getModelPerformance();
      if (mounted) {
        setState(() {
          models = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Model Version",
                        border: OutlineInputBorder(),
                      ),
                      items: models.map((m) => DropdownMenuItem<String>(
                        value: m['model_version'] as String,
                        child: Text(m['model_version'] ?? ''),
                      )).toList(),
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Dataset Version",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "v1.0", child: Text("v1.0")),
                        DropdownMenuItem(value: "v0.9", child: Text("v0.9")),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Date Range",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "all", child: Text("All Time")),
                        DropdownMenuItem(value: "30d", child: Text("Last 30 Days")),
                        DropdownMenuItem(value: "7d", child: Text("Last 7 Days")),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          
          // Metrics Cards
          if (models.isNotEmpty) ...[
            Row(
              children: [
                _metricCard("Accuracy", models[0]['accuracy'] ?? 0.0, const Color(0xFF1E88E5)),
                const SizedBox(width: 15),
                _metricCard("Precision", models[0]['precision'] ?? 0.0, const Color(0xFF43A047)),
                const SizedBox(width: 15),
                _metricCard("Recall", models[0]['recall'] ?? 0.0, const Color(0xFFFF9800)),
                const SizedBox(width: 15),
                _metricCard("F1 Score", models[0]['f1_score'] ?? 0.0, const Color(0xFF9C27B0)),
              ],
            ),
            const SizedBox(height: 25),
          ],
          
          // Confusion Matrix Placeholder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Confusion Matrix",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grid_on, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                            "Confusion Matrix Placeholder",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "Integration pending for AI model",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          
          // Model History
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Model Version History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  if (models.isEmpty)
                    const Text("No model data available")
                  else
                    DataTable(
                      columns: const [
                        DataColumn(label: Text("Model Name")),
                        DataColumn(label: Text("Version")),
                        DataColumn(label: Text("Dataset")),
                        DataColumn(label: Text("Accuracy")),
                        DataColumn(label: Text("Created")),
                      ],
                      rows: models.map((m) => DataRow(cells: [
                        DataCell(Text(m['model_name'] ?? '')),
                        DataCell(Text(m['model_version'] ?? '')),
                        DataCell(Text(m['training_dataset'] ?? '')),
                        DataCell(Text("${((m['accuracy'] ?? 0) * 100).toStringAsFixed(1)}%")),
                        DataCell(Text(m['created_at']?.toString().split('T')[0] ?? '')),
                      ])).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, double value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                "${(value * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================
// DATASET COVERAGE
// ========================

class DatasetCoverageScreen extends StatefulWidget {
  const DatasetCoverageScreen({super.key});

  @override
  State<DatasetCoverageScreen> createState() => _DatasetCoverageScreenState();
}

class _DatasetCoverageScreenState extends State<DatasetCoverageScreen> {
  Map<String, dynamic> signDistribution = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.getSignDistribution();
      if (mounted) {
        setState(() {
          signDistribution = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sign Class Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sign Class Distribution",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  if (signDistribution.isEmpty)
                    const Text("No data available")
                  else
                    ...signDistribution.entries.map((entry) {
                      final category = entry.key;
                      final signs = entry.value as List;
                      final total = signs.fold<int>(0, (sum, item) => sum + (item['count'] ?? 0) as int);
                      return ExpansionTile(
                        title: Text(category),
                        subtitle: Text("$total videos"),
                        children: signs.map<Widget>((sign) {
                          return ListTile(
                            title: Text(sign['sign_name'] ?? ''),
                            trailing: Text("${sign['count'] ?? 0}"),
                          );
                        }).toList(),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          
          // Medical Category Coverage
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Medical Category Coverage",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: signDistribution.keys.map((category) {
                      final signs = signDistribution[category] as List;
                      final total = signs.fold<int>(0, (sum, item) => sum + (item['count'] ?? 0) as int);
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: _getCategoryColor(category),
                          child: Text(
                            "$total",
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                        label: Text(category.toString()),
                        backgroundColor: _getCategoryColor(category).withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          
          // Low Sample Warnings
          Card(
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.amber),
                      SizedBox(width: 10),
                      Text(
                        "Dataset Balance Warnings",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (signDistribution.isEmpty)
                    const Text("No warning at this time.")
                  else
                    Text(
                      "Sign classes with low sample sizes need more data collection.",
                      style: const TextStyle(color: Colors.black87),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    final colors = {
      'Symptoms': const Color(0xFF1E88E5),
      'Diagnosis': const Color(0xFF43A047),
      'Basic Expression': const Color(0xFFFF9800),
      'Emergency': const Color(0xFFE91E63),
      'Medical Personnel': const Color(0xFF9C27B0),
      'Medical Facility': const Color(0xFF00BCD4),
      'Treatment': const Color(0xFF795548),
      'Basic Need': const Color(0xFF607D8B),
    };
    return colors[category] ?? const Color(0xFF1E88E5);
  }
}

// ========================
// REAL-TIME MONITORING
// ========================

class RealTimeMonitoringScreen extends StatefulWidget {
  const RealTimeMonitoringScreen({super.key});

  @override
  State<RealTimeMonitoringScreen> createState() => _RealTimeMonitoringScreenState();
}

class _RealTimeMonitoringScreenState extends State<RealTimeMonitoringScreen> {
  List<dynamic> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.getInferenceLogs(limit: 20);
      if (mounted) {
        setState(() {
          logs = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Inference Logs",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refresh"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (logs.isEmpty)
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.table_chart, size: 50, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "No inference logs yet",
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              "This feature is ready for future AI model integration",
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    DataTable(
                      columns: const [
                        DataColumn(label: Text("Timestamp")),
                        DataColumn(label: Text("Predicted Sign")),
                        DataColumn(label: Text("Confidence")),
                        DataColumn(label: Text("Device")),
                        DataColumn(label: Text("Latency")),
                      ],
                      rows: logs.map((log) => DataRow(cells: [
                        DataCell(Text(log['timestamp']?.toString().split('.').first ?? '')),
                        DataCell(Text(log['predicted_sign'] ?? '-')),
                        DataCell(Text(log['confidence_score'] != null 
                            ? "${(log['confidence_score'] * 100).toStringAsFixed(1)}%" 
                            : '-')),
                        DataCell(Text(log['device_type'] ?? '-')),
                        DataCell(Text(log['latency_ms'] != null 
                            ? "${log['latency_ms']}ms" 
                            : '-')),
                      ])).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================
// SCHOOL MAP
// ========================

class SchoolMapScreen extends StatefulWidget {
  const SchoolMapScreen({super.key});

  @override
  State<SchoolMapScreen> createState() => _SchoolMapScreenState();
}

class _SchoolMapScreenState extends State<SchoolMapScreen> {
  List<dynamic> schools = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await ApiService.getSchoolMap();
      if (mounted) {
        setState(() {
          schools = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Uganda School Locations",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 15),
                          Text(
                            "School Map Visualization",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${schools.length} schools registered",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 20),
                          if (schools.isEmpty)
                            const Text(
                              "No school location data available",
                              style: TextStyle(color: Colors.grey),
                            )
                          else
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: schools.map<Widget>((school) {
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          school['school_name'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${school['region'] ?? ''}, ${school['district'] ?? ''}",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          "Videos: ${school['video_count'] ?? 0}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
