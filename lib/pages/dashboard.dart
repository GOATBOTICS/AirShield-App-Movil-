import 'package:airshield/constants.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> cardsData = [
      {
        "icon": Icons.thermostat,
        "iconColor": Colors.red,
        "circleColor": Colors.red,
        "value": "28°C",
        "label": "Temperatura",
      },
      {
        "icon": Icons.water_drop,
        "iconColor": Colors.blue,
        "circleColor": Colors.blue,
        "value": "65%",
        "label": "Humidity",
      },
      {
        "icon": Icons.speed,
        "iconColor": Colors.purple,
        "circleColor": Colors.purple,
        "value": "1013",
        "label": "Pressure (hPa)",
      },
      {
        "icon": Icons.air,
        "iconColor": Color(0xFF06B6D4),
        "circleColor": Color(0xFF06B6D4),
        "value": "12",
        "label": "Wind (km/h)",
      },
    ];

    return Scaffold(
      backgroundColor: Color(0xFFEFF8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: EdgeInsetsGeometry.all(12),
              child: Column(
                children: [
                  // Barra de airshield
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color.fromARGB(255, 65, 166, 249),
                                  Color.fromARGB(255, 3, 50, 120),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.shield,
                              size: 26,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AirShield",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                  color: colorFuerte,
                                ),
                              ),
                              Text(
                                "Dashboard",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                            ),
                            icon: Icon(Icons.refresh),
                          ),
                          IconButton(
                            style: ButtonStyle(
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              backgroundColor: WidgetStatePropertyAll(
                                Colors.white,
                              ),
                            ),
                            onPressed: () {},
                            icon: Icon(Icons.settings),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Card azul
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Air Quality Index",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 29,
                                  ),
                                ),
                                Text(
                                  "Real-time monitoring",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: Color(0x33ffffff),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.air,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "42",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 45,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  "Good",
                                  style: TextStyle(
                                    color: Colors.green.shade300,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  "Last updated",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "2 min ago",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),

                  // Grid de temperatura, humedad, presion, viento
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    itemCount: cardsData.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 4
                          : 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: MediaQuery.of(context).size.width > 900
                          ? 1
                          : MediaQuery.of(context).size.width > 600
                          ? 0.65
                          : 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final card = cardsData[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    card["icon"],
                                    color: card["iconColor"],
                                    size: 28,
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: card["circleColor"],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 100),
                              Column(
                                children: [
                                  Text(
                                    card["value"],
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    card["label"],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12),

                  // Calidad del aire a detalle
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Air Quality Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Icon(Icons.info_outline),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("PM2.5"),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("12"),
                                  SizedBox(width: 4),
                                  Text("µg/m^2"),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("PM10"),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("28"),
                                  SizedBox(width: 4),
                                  Text("µg/m^2"),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("NO2"),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("18"),
                                  SizedBox(width: 4),
                                  Text("ppb"),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text("O3"),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("45"),
                                  SizedBox(width: 4),
                                  Text("ppb"),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Recomendaciones de la salud
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Health Recommendations",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Icon(Icons.shield_rounded, color: Colors.green),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              border: Border.all(color: Colors.green, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "Air quality is good for outdoor activities",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Perfect conditions for exercise and outdoor sports",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              border: Border.all(
                                color: Colors.orange,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "Sensitive individuals should limit prolonged outdoor exertion",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "People with respiratory conditions should be cautios",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Localización y siguiente update
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card 1 - Location
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.blueAccent,
                                  size: 28,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Location",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    height: 0.9,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Mexico City",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // Card 2 - Next Update
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.blueAccent,
                                  size: 28,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Next update",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    height: 0.9,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "In 8 minutes",
                                  style: TextStyle(fontSize: 14),
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
            ),
          ),
        ),
      ),
    );
  }
}
