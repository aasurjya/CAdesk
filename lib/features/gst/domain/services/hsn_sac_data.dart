import 'package:ca_app/features/gst/domain/models/hsn_sac_code.dart';

/// Master database of HSN and SAC codes with GST rates.
///
/// Contains 50+ HSN codes and 20+ SAC codes covering common goods
/// and services in Indian GST.
const List<HsnSacCode> hsnSacMasterDatabase = [
  // ─── Chapter 01: Live Animals ───
  HsnSacCode(
    code: '0102',
    description: 'Live bovine animals',
    type: HsnSacType.hsn,
    chapter: 1,
    gstRate: 0.0,
  ),

  // ─── Chapter 02: Meat ───
  HsnSacCode(
    code: '0201',
    description: 'Meat of bovine animals, fresh or chilled',
    type: HsnSacType.hsn,
    chapter: 2,
    gstRate: 0.0,
  ),

  // ─── Chapter 04: Dairy Products ───
  HsnSacCode(
    code: '0401',
    description: 'Milk and cream, not concentrated',
    type: HsnSacType.hsn,
    chapter: 4,
    gstRate: 0.0,
  ),
  HsnSacCode(
    code: '0402',
    description: 'Milk and cream, concentrated or sweetened',
    type: HsnSacType.hsn,
    chapter: 4,
    gstRate: 5.0,
  ),

  // ─── Chapter 07: Vegetables ───
  HsnSacCode(
    code: '0701',
    description: 'Potatoes, fresh or chilled',
    type: HsnSacType.hsn,
    chapter: 7,
    gstRate: 0.0,
  ),
  HsnSacCode(
    code: '0713',
    description: 'Dried leguminous vegetables (pulses)',
    type: HsnSacType.hsn,
    chapter: 7,
    gstRate: 0.0,
  ),

  // ─── Chapter 08: Fruits ───
  HsnSacCode(
    code: '0803',
    description: 'Bananas including plantains, fresh or dried',
    type: HsnSacType.hsn,
    chapter: 8,
    gstRate: 0.0,
  ),

  // ─── Chapter 09: Coffee, Tea, Spices ───
  HsnSacCode(
    code: '0901',
    description: 'Coffee, whether or not roasted',
    type: HsnSacType.hsn,
    chapter: 9,
    gstRate: 5.0,
  ),
  HsnSacCode(
    code: '0902',
    description: 'Tea, whether or not flavoured',
    type: HsnSacType.hsn,
    chapter: 9,
    gstRate: 5.0,
  ),

  // ─── Chapter 10: Cereals ───
  HsnSacCode(
    code: '1001',
    description: 'Wheat and meslin',
    type: HsnSacType.hsn,
    chapter: 10,
    gstRate: 5.0,
  ),
  HsnSacCode(
    code: '1005',
    description: 'Maize (corn)',
    type: HsnSacType.hsn,
    chapter: 10,
    gstRate: 5.0,
  ),
  HsnSacCode(
    code: '1006',
    description: 'Rice',
    type: HsnSacType.hsn,
    chapter: 10,
    gstRate: 5.0,
  ),

  // ─── Chapter 11: Milling Products ───
  HsnSacCode(
    code: '1101',
    description: 'Wheat or meslin flour',
    type: HsnSacType.hsn,
    chapter: 11,
    gstRate: 5.0,
  ),

  // ─── Chapter 15: Fats and Oils ───
  HsnSacCode(
    code: '1507',
    description: 'Soya-bean oil and its fractions',
    type: HsnSacType.hsn,
    chapter: 15,
    gstRate: 5.0,
  ),
  HsnSacCode(
    code: '1511',
    description: 'Palm oil and its fractions',
    type: HsnSacType.hsn,
    chapter: 15,
    gstRate: 5.0,
  ),

  // ─── Chapter 17: Sugars ───
  HsnSacCode(
    code: '1701',
    description: 'Cane or beet sugar and chemically pure sucrose',
    type: HsnSacType.hsn,
    chapter: 17,
    gstRate: 5.0,
  ),

  // ─── Chapter 19: Preparations of cereals ───
  HsnSacCode(
    code: '1905',
    description: 'Bread, pastry, cakes, biscuits',
    type: HsnSacType.hsn,
    chapter: 19,
    gstRate: 18.0,
  ),

  // ─── Chapter 21: Miscellaneous edible preparations ───
  HsnSacCode(
    code: '2106',
    description: 'Food preparations not elsewhere specified',
    type: HsnSacType.hsn,
    chapter: 21,
    gstRate: 18.0,
  ),

  // ─── Chapter 22: Beverages ───
  HsnSacCode(
    code: '2201',
    description: 'Waters, including mineral and aerated waters',
    type: HsnSacType.hsn,
    chapter: 22,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '2202',
    description: 'Aerated waters with added sugar or flavour',
    type: HsnSacType.hsn,
    chapter: 22,
    gstRate: 28.0,
    cessRate: 12.0,
  ),

  // ─── Chapter 24: Tobacco ───
  HsnSacCode(
    code: '2402',
    description: 'Cigars, cheroots, cigarillos and cigarettes',
    type: HsnSacType.hsn,
    chapter: 24,
    gstRate: 28.0,
    cessRate: 36.0,
  ),
  HsnSacCode(
    code: '2401',
    description: 'Unmanufactured tobacco; tobacco refuse',
    type: HsnSacType.hsn,
    chapter: 24,
    gstRate: 28.0,
    cessRate: 5.0,
  ),

  // ─── Chapter 25: Salt, Sulphur, Cement ───
  HsnSacCode(
    code: '2523',
    description: 'Portland cement, aluminous cement, slag cement',
    type: HsnSacType.hsn,
    chapter: 25,
    gstRate: 28.0,
  ),
  HsnSacCode(
    code: '2501',
    description: 'Salt (including table salt and denatured salt)',
    type: HsnSacType.hsn,
    chapter: 25,
    gstRate: 0.0,
  ),

  // ─── Chapter 27: Mineral fuels ───
  HsnSacCode(
    code: '2710',
    description: 'Petroleum oils and preparations',
    type: HsnSacType.hsn,
    chapter: 27,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '2711',
    description: 'Petroleum gases and other gaseous hydrocarbons',
    type: HsnSacType.hsn,
    chapter: 27,
    gstRate: 5.0,
  ),

  // ─── Chapter 30: Pharmaceutical products ───
  HsnSacCode(
    code: '3004',
    description: 'Medicaments for therapeutic or prophylactic uses',
    type: HsnSacType.hsn,
    chapter: 30,
    gstRate: 12.0,
  ),

  // ─── Chapter 33: Essential oils, cosmetics ───
  HsnSacCode(
    code: '3304',
    description: 'Beauty or make-up preparations',
    type: HsnSacType.hsn,
    chapter: 33,
    gstRate: 28.0,
  ),

  // ─── Chapter 39: Plastics ───
  HsnSacCode(
    code: '3901',
    description: 'Polymers of ethylene, in primary forms',
    type: HsnSacType.hsn,
    chapter: 39,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '3923',
    description: 'Articles for conveyance or packing of goods, of plastics',
    type: HsnSacType.hsn,
    chapter: 39,
    gstRate: 18.0,
  ),

  // ─── Chapter 40: Rubber ───
  HsnSacCode(
    code: '4001',
    description: 'Natural rubber, in primary forms or plates',
    type: HsnSacType.hsn,
    chapter: 40,
    gstRate: 5.0,
  ),
  HsnSacCode(
    code: '4011',
    description: 'New pneumatic tyres, of rubber',
    type: HsnSacType.hsn,
    chapter: 40,
    gstRate: 28.0,
  ),

  // ─── Chapter 41: Leather ───
  HsnSacCode(
    code: '4107',
    description: 'Leather further prepared after tanning',
    type: HsnSacType.hsn,
    chapter: 41,
    gstRate: 12.0,
  ),

  // ─── Chapter 48: Paper ───
  HsnSacCode(
    code: '4802',
    description: 'Uncoated paper for writing or printing',
    type: HsnSacType.hsn,
    chapter: 48,
    gstRate: 12.0,
  ),
  HsnSacCode(
    code: '4819',
    description: 'Cartons, boxes, cases, of paper or paperboard',
    type: HsnSacType.hsn,
    chapter: 48,
    gstRate: 18.0,
  ),

  // ─── Chapter 52: Cotton ───
  HsnSacCode(
    code: '5201',
    description: 'Cotton, not carded or combed',
    type: HsnSacType.hsn,
    chapter: 52,
    gstRate: 5.0,
  ),
  HsnSacCode(
    code: '5208',
    description: 'Woven fabrics of cotton',
    type: HsnSacType.hsn,
    chapter: 52,
    gstRate: 5.0,
  ),

  // ─── Chapter 61: Apparel (knitted) ───
  HsnSacCode(
    code: '6109',
    description: 'T-shirts, singlets and other vests, knitted',
    type: HsnSacType.hsn,
    chapter: 61,
    gstRate: 5.0,
  ),

  // ─── Chapter 62: Apparel (not knitted) ───
  HsnSacCode(
    code: '6203',
    description: 'Mens suits, jackets, trousers (not knitted)',
    type: HsnSacType.hsn,
    chapter: 62,
    gstRate: 12.0,
  ),

  // ─── Chapter 64: Footwear ───
  HsnSacCode(
    code: '6403',
    description: 'Footwear with outer soles of rubber or plastics',
    type: HsnSacType.hsn,
    chapter: 64,
    gstRate: 18.0,
  ),

  // ─── Chapter 69: Ceramic products ───
  HsnSacCode(
    code: '6907',
    description: 'Ceramic flags and paving, hearth or wall tiles',
    type: HsnSacType.hsn,
    chapter: 69,
    gstRate: 18.0,
  ),

  // ─── Chapter 70: Glass ───
  HsnSacCode(
    code: '7001',
    description: 'Cullet and other waste of glass; glass in mass',
    type: HsnSacType.hsn,
    chapter: 70,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '7005',
    description: 'Float glass and surface ground glass',
    type: HsnSacType.hsn,
    chapter: 70,
    gstRate: 18.0,
  ),

  // ─── Chapter 71: Precious metals, jewellery ───
  HsnSacCode(
    code: '7113',
    description: 'Articles of jewellery of precious metal',
    type: HsnSacType.hsn,
    chapter: 71,
    gstRate: 3.0,
  ),
  HsnSacCode(
    code: '7108',
    description: 'Gold (including gold plated with platinum)',
    type: HsnSacType.hsn,
    chapter: 71,
    gstRate: 3.0,
  ),

  // ─── Chapter 72: Iron and Steel ───
  HsnSacCode(
    code: '7206',
    description: 'Iron and non-alloy steel ingots',
    type: HsnSacType.hsn,
    chapter: 72,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '7210',
    description: 'Flat-rolled products of iron, coated',
    type: HsnSacType.hsn,
    chapter: 72,
    gstRate: 18.0,
  ),

  // ─── Chapter 73: Articles of iron or steel ───
  HsnSacCode(
    code: '7308',
    description: 'Structures and parts of structures, of iron or steel',
    type: HsnSacType.hsn,
    chapter: 73,
    gstRate: 18.0,
  ),

  // ─── Chapter 76: Aluminium ───
  HsnSacCode(
    code: '7601',
    description: 'Unwrought aluminium',
    type: HsnSacType.hsn,
    chapter: 76,
    gstRate: 18.0,
  ),

  // ─── Chapter 84: Machinery ───
  HsnSacCode(
    code: '8471',
    description: 'Automatic data processing machines (computers)',
    type: HsnSacType.hsn,
    chapter: 84,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '8443',
    description: 'Printing machinery; printers and copiers',
    type: HsnSacType.hsn,
    chapter: 84,
    gstRate: 18.0,
  ),

  // ─── Chapter 85: Electrical machinery ───
  HsnSacCode(
    code: '8504',
    description: 'Electrical transformers and static converters',
    type: HsnSacType.hsn,
    chapter: 85,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '8517',
    description: 'Telephone sets and smartphones',
    type: HsnSacType.hsn,
    chapter: 85,
    gstRate: 18.0,
  ),

  // ─── Chapter 87: Vehicles ───
  HsnSacCode(
    code: '8703',
    description: 'Motor cars and vehicles for transport of persons',
    type: HsnSacType.hsn,
    chapter: 87,
    gstRate: 28.0,
    cessRate: 15.0,
  ),
  HsnSacCode(
    code: '8708',
    description: 'Parts and accessories of motor vehicles',
    type: HsnSacType.hsn,
    chapter: 87,
    gstRate: 28.0,
  ),

  // ─── Chapter 94: Furniture ───
  HsnSacCode(
    code: '9401',
    description: 'Seats and chairs (excluding medical furniture)',
    type: HsnSacType.hsn,
    chapter: 94,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '9403',
    description: 'Other furniture and parts thereof',
    type: HsnSacType.hsn,
    chapter: 94,
    gstRate: 18.0,
  ),

  // ─── Chapter 96: Miscellaneous manufactured articles ───
  HsnSacCode(
    code: '9608',
    description: 'Ball point pens, felt tipped pens, markers',
    type: HsnSacType.hsn,
    chapter: 96,
    gstRate: 18.0,
  ),

  // ═══════════════════════════════════════════════════════
  // SAC CODES (Services)
  // ═══════════════════════════════════════════════════════

  // ─── Legal Services ───
  HsnSacCode(
    code: '9982',
    description: 'Legal services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '998211',
    description: 'Legal advisory and representation services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Accounting Services ───
  HsnSacCode(
    code: '998221',
    description: 'Accounting, auditing and bookkeeping services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '998222',
    description: 'Tax consultancy and preparation services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── IT Services ───
  HsnSacCode(
    code: '998314',
    description: 'IT design and development services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '998313',
    description: 'IT consulting and support services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Management Consulting ───
  HsnSacCode(
    code: '998311',
    description: 'Management consulting and management services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Transport Services ───
  HsnSacCode(
    code: '9965',
    description: 'Goods transport services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 5.0,
  ),
  HsnSacCode(
    code: '9964',
    description: 'Passenger transport services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 5.0,
  ),
  HsnSacCode(
    code: '9967',
    description: 'Supporting services in transport',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Construction Services ───
  HsnSacCode(
    code: '9954',
    description: 'Construction services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Education Services ───
  HsnSacCode(
    code: '9992',
    description: 'Education services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Healthcare Services ───
  HsnSacCode(
    code: '9993',
    description: 'Human health and social care services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Accommodation and Food Services ───
  HsnSacCode(
    code: '9963',
    description: 'Accommodation, food and beverage services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Telecom Services ───
  HsnSacCode(
    code: '9984',
    description: 'Telecommunication, broadcasting and information services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Banking and Financial Services ───
  HsnSacCode(
    code: '9971',
    description: 'Financial and related services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Insurance Services ───
  HsnSacCode(
    code: '997131',
    description: 'Life insurance services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '997132',
    description: 'General insurance services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Real Estate Services ───
  HsnSacCode(
    code: '9972',
    description: 'Real estate services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Rental and Leasing Services ───
  HsnSacCode(
    code: '9966',
    description: 'Rental services of transport vehicles',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),
  HsnSacCode(
    code: '9973',
    description: 'Leasing or rental services without operator',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Security Services ───
  HsnSacCode(
    code: '9985',
    description: 'Support services including security and manpower',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Maintenance and Repair Services ───
  HsnSacCode(
    code: '9987',
    description: 'Maintenance, repair and installation services',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),

  // ─── Employment Services ───
  HsnSacCode(
    code: '9985111',
    description: 'Employment services including labour supply',
    type: HsnSacType.sac,
    chapter: 99,
    gstRate: 18.0,
  ),
];
