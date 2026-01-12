import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math'; // For calculating Min/Max

class AgriStatsDashboard extends StatefulWidget {
  const AgriStatsDashboard({super.key});

  @override
  State<AgriStatsDashboard> createState() => _AgriStatsDashboardState();
}

class _AgriStatsDashboardState extends State<AgriStatsDashboard> {
  final _supabase = Supabase.instance.client;

  // --- Data State ---
  Map<String, int> roleCounts = {'Farmer': 0, 'Buyer': 0, 'Inspector': 0};
  int totalUsers = 0;
  List<Map<String, dynamic>> demandData = [];
  double avgDemand = 0.0; // Calculated average
  List<FlSpot> priceSpots = [];
  List<String> priceMonths = [];
  double maxPrice = 0;
  double minPrice = 0;

  bool isLoading = true;
  String lastUpdated = "Syncing...";
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchRealStats();
  }

  Future<void> _fetchRealStats() async {
    try {
      final farmers = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'farmer')
          .count();
      final buyers =
          await _supabase.from('profiles').select().eq('role', 'buyer').count();
      final inspectors = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'inspector')
          .count();

      final demandRes = await _supabase
          .from('market_demand')
          .select()
          .order('demand_percentage', ascending: false)
          .limit(5);
      final priceRes = await _supabase
          .from('price_trends')
          .select()
          .order('id', ascending: true);

      if (mounted) {
        setState(() {
          // 1. Roles
          int f = farmers.count;
          int b = buyers.count;
          int i = inspectors.count;
          if (f == 0 && b == 0 && i == 0) {
            f = 65;
            b = 25;
            i = 10;
          }
          roleCounts = {'Farmer': f, 'Buyer': b, 'Inspector': i};
          totalUsers = f + b + i;

          // 2. Demand & Average Logic
          if (demandRes.isNotEmpty) {
            demandData = List<Map<String, dynamic>>.from(demandRes);
          } else {
            demandData = [
              {'commodity_name': 'Onion', 'demand_percentage': 88},
              {'commodity_name': 'Tomato', 'demand_percentage': 65},
              {'commodity_name': 'Rice', 'demand_percentage': 45},
              {'commodity_name': 'Wheat', 'demand_percentage': 30},
              {'commodity_name': 'Cotton', 'demand_percentage': 20},
            ];
          }
          // Calculate Average Demand for the "Line"
          double totalDem = 0;
          for (var item in demandData)
            totalDem += (item['demand_percentage'] as num).toDouble();
          avgDemand = totalDem / demandData.length;

          // 3. Price & Min/Max Logic
          if (priceRes.isNotEmpty) {
            priceSpots = (priceRes as List).asMap().entries.map((e) {
              return FlSpot(
                  e.key.toDouble(), (e.value['price_index'] as num).toDouble());
            }).toList();
            priceMonths = (priceRes as List)
                .map((e) => e['month_name'].toString())
                .toList();
          } else {
            priceSpots = const [
              FlSpot(0, 20),
              FlSpot(1, 45),
              FlSpot(2, 30),
              FlSpot(3, 60),
              FlSpot(4, 55)
            ];
            priceMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
          }

          // Calculate Min/Max for highlights
          if (priceSpots.isNotEmpty) {
            maxPrice = priceSpots.map((e) => e.y).reduce(max);
            minPrice = priceSpots.map((e) => e.y).reduce(min);
          }

          lastUpdated =
              "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}";
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator(color: Colors.green)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Market Intelligence",
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900])),
                  Text("Updated: $lastUpdated",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
              _buildLiveBadge()
            ],
          ),
        ),

        const SizedBox(height: 15),

        // 1. ECOSYSTEM (Donut)
        _buildDetailCard(
          title: "User Ecosystem",
          child: Row(
            children: [
              SizedBox(
                height: 130,
                width: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 35,
                        sections: [
                          _pieSection(roleCounts['Farmer']!, Colors.green,
                              isTouched: _touchedIndex == 0),
                          _pieSection(roleCounts['Buyer']!, Colors.blue,
                              isTouched: _touchedIndex == 1),
                          _pieSection(roleCounts['Inspector']!, Colors.orange,
                              isTouched: _touchedIndex == 2),
                        ],
                        pieTouchData: PieTouchData(touchCallback: (e, r) {
                          setState(() => _touchedIndex =
                              (e.isInterestedForInteractions &&
                                      r?.touchedSection != null)
                                  ? r!.touchedSection!.touchedSectionIndex
                                  : -1);
                        }),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("$totalUsers",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Active",
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendRow(Colors.green, "Farmers", roleCounts['Farmer']!,
                        totalUsers),
                    const SizedBox(height: 8),
                    _legendRow(Colors.blue, "Buyers", roleCounts['Buyer']!,
                        totalUsers),
                    const SizedBox(height: 8),
                    _legendRow(Colors.orange, "Inspectors",
                        roleCounts['Inspector']!, totalUsers),
                  ],
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. DEMAND INSIGHTS (Bar Chart with Average Line)
        _buildDetailCard(
          title: "Demand vs Average",
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1.6,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${demandData[group.x.toInt()]['commodity_name']}\n',
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                            children: [
                              TextSpan(
                                  text: '${rod.toY.round()}%',
                                  style: TextStyle(color: Colors.yellowAccent))
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= demandData.length)
                              return const Text('');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                  demandData[value.toInt()]['commodity_name']
                                      .toString()
                                      .substring(0, 3),
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600])),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      // INSIGHT: Visualizing the Average Line
                      getDrawingHorizontalLine: (value) {
                        if ((value - avgDemand).abs() < 1) {
                          // Draw line near average
                          return FlLine(
                              color: Colors.blue.withOpacity(0.5),
                              strokeWidth: 2,
                              dashArray: [5, 5]);
                        }
                        return FlLine(color: Colors.transparent);
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: demandData.asMap().entries.map((e) {
                      final val =
                          (e.value['demand_percentage'] as num).toDouble();
                      // INSIGHT: Color logic based on Average
                      final bool isAboveAvg = val >= avgDemand;

                      return BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: val,
                            // Gradient Visuals
                            gradient: LinearGradient(
                              colors: isAboveAvg
                                  ? [Colors.green, Colors.greenAccent] // Good
                                  : [Colors.orange, Colors.orangeAccent], // Low
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 16,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                            backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 100,
                                color: Colors.grey.withOpacity(0.05)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chartLegend(Colors.green, "Above Avg"),
                  const SizedBox(width: 15),
                  _chartLegend(Colors.orange, "Below Avg"),
                  const SizedBox(width: 15),
                  // Dotted line legend
                  Row(children: [
                    Container(
                        height: 2,
                        width: 15,
                        decoration: BoxDecoration(color: Colors.blue[300])),
                    const SizedBox(width: 4),
                    Text("Avg Line",
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey[600]))
                  ])
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. PRICE PEAKS & DIPS (Line Chart with Markers)
        _buildDetailCard(
          title: "Price Volatility (₹)",
          child: AspectRatio(
            aspectRatio: 1.7,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey[100], strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 25,
                      getTitlesWidget: (value, meta) => Text(
                          '₹${value.toInt()}',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < priceMonths.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(priceMonths[value.toInt()],
                                style: GoogleFonts.poppins(
                                    fontSize: 10, color: Colors.grey[600])),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: priceSpots.length.toDouble() - 1,
                minY: 0,
                maxY: maxPrice + 10, // Dynamic height
                lineBarsData: [
                  LineChartBarData(
                    spots: priceSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: Colors.blue[700],
                    barWidth: 3,
                    isStrokeCapRound: true,
                    // INSIGHT: Custom Dot Painter for Min/Max
                    dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          if (spot.y == maxPrice) {
                            return FlDotCirclePainter(
                                radius: 6,
                                color: Colors.green,
                                strokeWidth: 2,
                                strokeColor: Colors.white);
                          } else if (spot.y == minPrice) {
                            return FlDotCirclePainter(
                                radius: 6,
                                color: Colors.red,
                                strokeWidth: 2,
                                strokeColor: Colors.white);
                          }
                          return FlDotCirclePainter(
                              radius: 0,
                              color: Colors.transparent); // Hide others
                        }),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.2),
                          Colors.transparent
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        String label = "";
                        if (spot.y == maxPrice) label = " (High)";
                        if (spot.y == minPrice) label = " (Low)";
                        return LineTooltipItem(
                          '₹${spot.y.toInt()}$label',
                          const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- HELPERS ---
  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green)),
      child: Row(
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text("ONLINE",
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildDetailCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const Divider(height: 20, thickness: 0.5),
          child,
        ],
      ),
    );
  }

  PieChartSectionData _pieSection(int value, Color color,
      {bool isTouched = false}) {
    final double radius = isTouched ? 45 : 35;
    return PieChartSectionData(
        color: color, value: value.toDouble(), title: '', radius: radius);
  }

  Widget _legendRow(Color color, String label, int count, int total) {
    int percentage = total > 0 ? ((count / total) * 100).round() : 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Flexible(
          child: Text("$label ($percentage%)",
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _chartLegend(Color color, String text) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
