import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../models/waste_type.dart';

class WasteGuideRepository {
  final FirebaseFirestore _firestore;

  WasteGuideRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<WasteType>> watchWasteTypes() {
    return _firestore.collection(FirebaseConstants.colWasteTypes).snapshots().map((snap) {
      if (snap.docs.isEmpty) {
        return _fallbackWasteTypes;
      }
      final items = snap.docs.map((d) => WasteType.fromFirestore(d.id, d.data())).toList();
      return items.isNotEmpty ? items : _fallbackWasteTypes;
    });
  }

  static final List<WasteType> _fallbackWasteTypes = [
    const WasteType(
      id: 'plastic',
      name: 'Plastic Waste',
      category: 'Plastic',
      description: 'Bottles, containers, clean packaging bags, and clean plastic wraps.',
      instruction: 'Clean and dry all plastic containers thoroughly before dropping them into the dry bin.',
      disposalTips: ['Rinse out milk and beverage pouches', 'Remove caps and labels if easily detachable', 'Do not mix with food waste'],
      icon: '🥤',
    ),
    const WasteType(
      id: 'organic',
      name: 'Organic & Food',
      category: 'Organic',
      description: 'Vegetable scraps, fruit peels, leftover cooked food, garden clippings, and tea grounds.',
      instruction: 'Segregate daily into the green biodegradable bin. Do not bag in non-biodegradable plastic.',
      disposalTips: ['Drain excess liquids', 'Keep bin tightly covered to prevent pests', 'Compost at home if pit available'],
      icon: '🌿',
    ),
    const WasteType(
      id: 'paper',
      name: 'Paper & Cardboard',
      category: 'Paper',
      description: 'Newspapers, cartons, cardboard boxes, magazines, envelopes, and dry paper bags.',
      instruction: 'Flatten cardboard boxes and bundle newspapers neatly. Must be clean and dry.',
      disposalTips: ['Do not include oily food-stained paper', 'Remove plastic tape from boxes', 'Store in dry area before collection'],
      icon: '📄',
    ),
    const WasteType(
      id: 'glass',
      name: 'Glass Containers',
      category: 'Glass',
      description: 'Glass bottles, jars, glass flasks, and beverage bottles.',
      instruction: 'Rinse glass jars and bottles. Never mix broken glass with regular recyclable items.',
      disposalTips: ['Wrap broken glass safely in paper before disposing', 'Do not include mirrors or light bulbs here', 'Keep separate from metals'],
      icon: '🍾',
    ),
    const WasteType(
      id: 'metal',
      name: 'Metal & Tins',
      category: 'Metal',
      description: 'Aluminum cans, food tins, bottle crowns, jar lids, and clean scrap metal.',
      instruction: 'Rinse cans to remove food remnants and flatten them to save space in the bin.',
      disposalTips: ['Rinse thoroughly to prevent odors', 'Compress aluminum drink cans', 'Keep separate from hazardous chemicals'],
      icon: '🥫',
    ),
    const WasteType(
      id: 'hazardous',
      name: 'Hazardous Waste',
      category: 'Hazardous',
      description: 'Paints, solvents, cleaning chemicals, expired medications, pesticides, and thermometers.',
      instruction: 'Keep in original sealed containers with labels intact. Hand over only on special collection days.',
      disposalTips: ['Never pour down drains or sewers', 'Keep out of reach of children', 'Store in cool ventilated space'],
      icon: '⚠️',
    ),
    const WasteType(
      id: 'ewaste',
      name: 'Electronic Waste (E-Waste)',
      category: 'E-Waste',
      description: 'Batteries, cables, mobile phones, chargers, broken electronics, and computer accessories.',
      instruction: 'Do not dismantle electronics. Bring to designated community e-waste collection drives.',
      disposalTips: ['Tape battery terminals to prevent short circuit', 'Wipe personal data before disposal', 'Keep dry and away from heat'],
      icon: '💻',
    ),
  ];
}
