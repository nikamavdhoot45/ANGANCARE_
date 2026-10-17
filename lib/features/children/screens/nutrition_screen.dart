import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

class NutritionScreen extends StatelessWidget {
  final String childName;

  const NutritionScreen({
    super.key,
    required this.childName,
  });

  String _t(
    BuildContext context,
    String english,
    String marathi,
    String hindi,
  ) {
    final languageCode = AppLocalizations.of(context).locale.languageCode;

    if (languageCode == 'mr') return marathi;
    if (languageCode == 'hi') return hindi;
    return english;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      appBar: AppBar(
        title: Text(
          _t(
            context,
            'Nutrition',
            'पोषण',
            'पोषण',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFFFFE1E7),
                    child: Icon(
                      Icons.restaurant_outlined,
                      color: Color(0xFFF45170),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(
                          context,
                          'Nutrition Plan',
                          'पोषण योजना',
                          'पोषण योजना',
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        childName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              _t(
                context,
                "Today's Nutrition",
                'आजचे पोषण',
                'आज का पोषण',
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNutritionCard(
                    icon: Icons.local_fire_department_outlined,
                    title: _t(
                      context,
                      'Calories',
                      'कॅलरीज',
                      'कैलोरी',
                    ),
                    value: '1,250',
                    unit: 'kcal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNutritionCard(
                    icon: Icons.water_drop_outlined,
                    title: _t(
                      context,
                      'Water',
                      'पाणी',
                      'पानी',
                    ),
                    value: '5',
                    unit: _t(
                      context,
                      'glasses',
                      'ग्लास',
                      'गिलास',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              _t(
                context,
                'Recommended Meals',
                'शिफारस केलेले आहार',
                'अनुशंसित भोजन',
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMealCard(
              icon: Icons.free_breakfast_outlined,
              meal: _t(
                context,
                'Breakfast',
                'नाश्ता',
                'नाश्ता',
              ),
              food: _t(
                context,
                'Poha + Milk',
                'पोहे + दूध',
                'पोहा + दूध',
              ),
              time: '8:00 AM',
            ),
            const SizedBox(height: 10),
            _buildMealCard(
              icon: Icons.lunch_dining_outlined,
              meal: _t(
                context,
                'Lunch',
                'दुपारचे जेवण',
                'दोपहर का भोजन',
              ),
              food: _t(
                context,
                'Rice + Dal + Vegetables',
                'भात + डाळ + भाज्या',
                'चावल + दाल + सब्जियाँ',
              ),
              time: '1:00 PM',
            ),
            const SizedBox(height: 10),
            _buildMealCard(
              icon: Icons.cookie_outlined,
              meal: _t(
                context,
                'Evening Snack',
                'संध्याकाळचा नाश्ता',
                'शाम का नाश्ता',
              ),
              food: _t(
                context,
                'Fruit + Milk',
                'फळ + दूध',
                'फल + दूध',
              ),
              time: '4:30 PM',
            ),
            const SizedBox(height: 10),
            _buildMealCard(
              icon: Icons.dinner_dining_outlined,
              meal: _t(
                context,
                'Dinner',
                'रात्रीचे जेवण',
                'रात का भोजन',
              ),
              food: _t(
                context,
                'Roti + Dal + Vegetables',
                'पोळी + डाळ + भाज्या',
                'रोटी + दाल + सब्जियाँ',
              ),
              time: '8:00 PM',
            ),
            const SizedBox(height: 22),
            Text(
              _t(
                context,
                'Nutrition Tips',
                'पोषण टिप्स',
                'पोषण सुझाव',
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(
                      context,
                      'Healthy habits',
                      'आरोग्यदायी सवयी',
                      'स्वस्थ आदतें',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _t(
                      context,
                      '• Include fruits and vegetables daily.',
                      '• दररोज फळे आणि भाज्यांचा समावेश करा.',
                      '• रोज फल और सब्जियाँ शामिल करें।',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _t(
                      context,
                      '• Give enough clean drinking water.',
                      '• पुरेसे स्वच्छ पिण्याचे पाणी द्या.',
                      '• पर्याप्त स्वच्छ पीने का पानी दें।',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _t(
                      context,
                      '• Include protein-rich foods in meals.',
                      '• आहारात प्रथिनेयुक्त पदार्थांचा समावेश करा.',
                      '• भोजन में प्रोटीन युक्त खाद्य पदार्थ शामिल करें।',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFF45170),
            size: 27,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard({
    required IconData icon,
    required String meal,
    required String food,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE1E7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF45170),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  food,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFF45170),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
