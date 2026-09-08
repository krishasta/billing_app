import '../models/product.dart';
import '../models/shop_profile.dart';

class DefaultData {
  static ShopProfile get defaultShopProfile => ShopProfile(
        shopName: 'Gopi Crackers',
        tagline: 'Sivakasi · Since 1994 | Direct Factory Price',
        phone: '+91 98420 11994',
        alternatePhone: '04562 274194',
        address: '14/3 Sattur Main Road, Sivakasi, Virudhunagar District, Tamil Nadu 626123',
        gstNumber: '33AABCA1994K1Z8',
        upiId: '9842011994@upi',
        defaultDiscountPercent: 81.0,
        termsAndConditions:
            '1. PESO Licence No. E/HQ/TN/22/1994 (S) - Batch tested under 125 dB limit.\n'
            '2. Light in open ground, one item at a time, never indoors.\n'
            '3. Keep a bucket of sand and water within arm\'s reach.\n'
            '4. Use an agarbatti to light — never a matchstick held close.\n'
            '5. Never return to a failed cracker for 10 minutes, then soak it.\n'
            '6. Children must be supervised on every item including sparklers.\n'
            '7. Crackers once sold cannot be returned or exchanged.\n'
            '8. Wishing you and your family a safe, prosperous & Happy Diwali!',
      );

  static List<String> get crackerCategories => [
        'All',
        'One Sound Crackers',
        'Wala',
        'Bijili Crackers',
        'Bomb',
        'Naattu Vedi',
        'Ground Chakkar',
        'Flower Pots',
        'Sky Shot Repeating',
        'Sky Shot Pack',
        'Sparklers',
        'Twinkling Stars',
        'Match Box',
        'Gift Box',
        'Family Pack',
        '2026 Series New Arrival',
      ];

  static List<Product> get defaultProducts => [
        // ==========================================
        // 1. ONE SOUND CRACKERS (81% Discount)
        // ==========================================
        Product(id: 'RC-001', name: '2 3/4 Kuruvi Crackers', category: 'One Sound Crackers', price: 36.84, unit: '1 PKT', subtitle: 'Net: ₹7.00'),
        Product(id: 'RC-002', name: '3 1/2 Lakshmi Crackers', category: 'One Sound Crackers', price: 78.95, unit: '1 PKT', subtitle: 'Net: ₹15.00'),
        Product(id: 'RC-003', name: '3 1/2 Flash Cracker', category: 'One Sound Crackers', price: 78.95, unit: '1 PKT', subtitle: 'Net: ₹15.00'),
        Product(id: 'RC-004', name: '3 1/2 Chotto Beam Cracker', category: 'One Sound Crackers', price: 78.95, unit: '1 PKT', subtitle: 'Net: ₹15.00'),
        Product(id: 'RC-005', name: '4" Ant Man Cracker', category: 'One Sound Crackers', price: 105.26, unit: '1 PKT', subtitle: 'Net: ₹20.00'),
        Product(id: 'RC-006', name: '4" Dora Cracker', category: 'One Sound Crackers', price: 105.26, unit: '1 PKT', subtitle: 'Net: ₹20.00'),
        Product(id: 'RC-007', name: '4" Zippy Cracker', category: 'One Sound Crackers', price: 105.26, unit: '1 PKT', subtitle: 'Net: ₹20.00'),
        Product(id: 'RC-008', name: '4" Dead Pool Deluxe (8 Ply)', category: 'One Sound Crackers', price: 178.95, unit: '1 PKT', subtitle: 'Net: ₹34.00'),
        Product(id: 'RC-009', name: '4" Lakshmi Deluxe (8 Ply)', category: 'One Sound Crackers', price: 178.95, unit: '1 PKT', subtitle: 'Net: ₹34.00'),
        Product(id: 'RC-010', name: '4" Little Singam Deluxe (8 Ply)', category: 'One Sound Crackers', price: 178.95, unit: '1 PKT', subtitle: 'Net: ₹34.00'),
        Product(id: 'RC-011', name: '4" Gold Ben 10 Deluxe (10 Ply)', category: 'One Sound Crackers', price: 189.47, unit: '1 PKT', subtitle: 'Net: ₹36.00'),
        Product(id: 'RC-012', name: '4" Thanos Mega Deluxe (12 Ply)', category: 'One Sound Crackers', price: 421.05, unit: '1 PKT', subtitle: 'Net: ₹80.00'),
        Product(id: 'RC-013', name: '4" Shiva Mega Deluxe (12 Ply)', category: 'One Sound Crackers', price: 421.05, unit: '1 PKT', subtitle: 'Net: ₹80.00'),
        Product(id: 'RC-014', name: '4" Lion Mega Deluxe (12 Ply)', category: 'One Sound Crackers', price: 421.05, unit: '1 PKT', subtitle: 'Net: ₹80.00'),

        // ==========================================
        // 2. WALA (81% Discount)
        // ==========================================
        Product(id: 'RC-015', name: '1K Wala', category: 'Wala', price: 1052.63, unit: '1 PKT', subtitle: 'Net: ₹200.00'),
        Product(id: 'RC-016', name: '2K Wala', category: 'Wala', price: 2105.26, unit: '1 PKT', subtitle: 'Net: ₹400.00'),
        Product(id: 'RC-017', name: '5K Wala', category: 'Wala', price: 5263.16, unit: '1 PKT', subtitle: 'Net: ₹1,000.00'),
        Product(id: 'RC-018', name: '10K Wala', category: 'Wala', price: 10526.32, unit: '1 PKT', subtitle: 'Net: ₹2,000.00'),

        // ==========================================
        // 3. BIJILI CRACKERS (81% Discount)
        // ==========================================
        Product(id: 'RC-019', name: 'Red Bijili Griviar Bag (50 Pcs)', category: 'Bijili Crackers', price: 105.26, unit: '1 PKT', subtitle: 'Net: ₹20.00'),
        Product(id: 'RC-020', name: 'Stripped Bijili Griviar Bag (50 Pcs)', category: 'Bijili Crackers', price: 105.26, unit: '1 PKT', subtitle: 'Net: ₹20.00'),
        Product(id: 'RC-021', name: 'Red Bijili Griviar Bag (100 Pcs)', category: 'Bijili Crackers', price: 210.53, unit: '1 PKT', subtitle: 'Net: ₹40.00'),
        Product(id: 'RC-022', name: 'Stripped Bijili Griviar Bag (100 Pcs)', category: 'Bijili Crackers', price: 210.53, unit: '1 PKT', subtitle: 'Net: ₹40.00'),
        Product(id: 'RC-023', name: 'Thunder Shower I', category: 'Bijili Crackers', price: 1789.47, unit: '1 PKT', subtitle: 'Net: ₹340.00'),
        Product(id: 'RC-024', name: 'Thunder Shower II', category: 'Bijili Crackers', price: 3052.63, unit: '1 PKT', subtitle: 'Net: ₹580.00'),
        Product(id: 'RC-025', name: 'Thunder Shower V', category: 'Bijili Crackers', price: 7889.47, unit: '1 PKT', subtitle: 'Net: ₹1,499.00'),
        Product(id: 'RC-026', name: 'Thunder Shower X', category: 'Bijili Crackers', price: 14205.26, unit: '1 PKT', subtitle: 'Net: ₹2,699.00'),

        // ==========================================
        // 4. BOMB (81% Discount)
        // ==========================================
        Product(id: 'RC-027', name: 'Atom Bomb', category: 'Bomb', price: 315.79, unit: '1 BOX', subtitle: 'Net: ₹60.00'),
        Product(id: 'RC-028', name: 'Hydro Bomb', category: 'Bomb', price: 473.68, unit: '1 BOX', subtitle: 'Net: ₹90.00'),
        Product(id: 'RC-029', name: 'King of King Bomb', category: 'Bomb', price: 631.58, unit: '1 BOX', subtitle: 'Net: ₹120.00'),

        // ==========================================
        // 5. NAATTU VEDI (81% Discount)
        // ==========================================
        Product(id: 'RC-030', name: '1/4 Kg Paper Bomb', category: 'Naattu Vedi', price: 263.16, unit: '1 PCE', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-031', name: '1/2 Kg Paper Bomb', category: 'Naattu Vedi', price: 526.32, unit: '1 PCE', subtitle: 'Net: ₹100.00'),
        Product(id: 'RC-032', name: '1 Kg Paper Bomb', category: 'Naattu Vedi', price: 1052.63, unit: '1 PCE', subtitle: 'Net: ₹200.00'),

        // ==========================================
        // 6. GROUND CHAKKAR (81% Discount)
        // ==========================================
        Product(id: 'RC-033', name: 'Ground Chakkar Big (25 pcs)', category: 'Ground Chakkar', price: 368.42, unit: '1 BOX', subtitle: 'Net: ₹70.00'),
        Product(id: 'RC-034', name: 'Ground Chakkar SPL', category: 'Ground Chakkar', price: 473.68, unit: '1 BOX', subtitle: 'Net: ₹90.00'),
        Product(id: 'RC-035', name: 'Ground Chakkar Ashoka', category: 'Ground Chakkar', price: 631.58, unit: '1 BOX', subtitle: 'Net: ₹120.00'),
        Product(id: 'RC-036', name: 'Ground Chakkar Deluxe', category: 'Ground Chakkar', price: 789.47, unit: '1 BOX', subtitle: 'Net: ₹150.00'),
        Product(id: 'RC-037', name: 'Ground Chakkar Spinner SPL', category: 'Ground Chakkar', price: 1052.63, unit: '1 BOX', subtitle: 'Net: ₹200.00'),
        Product(id: 'RC-038', name: 'Ground Chakkar Spinner DLX', category: 'Ground Chakkar', price: 1315.79, unit: '1 BOX', subtitle: 'Net: ₹250.00'),
        Product(id: 'RC-039', name: 'Wire Chakkar (Spl)', category: 'Ground Chakkar', price: 1315.79, unit: '1 BOX', subtitle: 'Net: ₹250.00'),
        Product(id: 'RC-040', name: 'Wire Chakkar (Dlx)', category: 'Ground Chakkar', price: 1578.95, unit: '1 BOX', subtitle: 'Net: ₹300.00'),

        // ==========================================
        // 7. FLOWER POTS (81% Discount)
        // ==========================================
        Product(id: 'RC-041', name: 'Flower Pots Small', category: 'Flower Pots', price: 210.53, unit: '1 BOX', subtitle: 'Net: ₹40.00'),
        Product(id: 'RC-042', name: 'Flower Pots Big', category: 'Flower Pots', price: 368.42, unit: '1 BOX', subtitle: 'Net: ₹70.00'),
        Product(id: 'RC-043', name: 'Flower Pots Special', category: 'Flower Pots', price: 473.68, unit: '1 BOX', subtitle: 'Net: ₹90.00'),
        Product(id: 'RC-044', name: 'Flower Pots Asoka', category: 'Flower Pots', price: 631.58, unit: '1 BOX', subtitle: 'Net: ₹120.00'),
        Product(id: 'RC-045', name: 'Flower Pots Colour Koti', category: 'Flower Pots', price: 1052.63, unit: '1 BOX', subtitle: 'Net: ₹200.00'),
        Product(id: 'RC-046', name: 'Flower Pots Deluxe', category: 'Flower Pots', price: 1315.79, unit: '1 BOX', subtitle: 'Net: ₹250.00'),
        Product(id: 'RC-047', name: 'Flower Colour Koti Deluxe', category: 'Flower Pots', price: 1578.95, unit: '1 BOX', subtitle: 'Net: ₹300.00'),
        Product(id: 'RC-048', name: 'Rome Pots', category: 'Flower Pots', price: 1578.95, unit: '1 BOX', subtitle: 'Net: ₹290.00'),

        // ==========================================
        // 8. SKY SHOT REPEATING MULTI COLOUR (81% Discount)
        // ==========================================
        Product(id: 'RC-049', name: '30 Shot Multi Colour', category: 'Sky Shot Repeating', price: 2000.00, unit: '1 BOX', subtitle: 'Net: ₹380.00'),
        Product(id: 'RC-050', name: '30 Shot Multi Colour (Premium)', category: 'Sky Shot Repeating', price: 2526.32, unit: '1 BOX', subtitle: 'Net: ₹480.00'),
        Product(id: 'RC-051', name: '60 Shot Multi Colour', category: 'Sky Shot Repeating', price: 4105.26, unit: '1 BOX', subtitle: 'Net: ₹780.00'),
        Product(id: 'RC-052', name: '60 Shot Multi Colour (Premium)', category: 'Sky Shot Repeating', price: 5157.89, unit: '1 BOX', subtitle: 'Net: ₹980.00'),
        Product(id: 'RC-053', name: '120 Shot Multi Colour', category: 'Sky Shot Repeating', price: 7894.74, unit: '1 BOX', subtitle: 'Net: ₹1,500.00'),
        Product(id: 'RC-054', name: '120 Shot Multi Colour (Premium)', category: 'Sky Shot Repeating', price: 10000.00, unit: '1 BOX', subtitle: 'Net: ₹1,900.00'),
        Product(id: 'RC-055', name: '240 Shot Multi Colour', category: 'Sky Shot Repeating', price: 15263.16, unit: '1 BOX', subtitle: 'Net: ₹2,900.00'),
        Product(id: 'RC-056', name: '240 Shot Multi Colour (Premium)', category: 'Sky Shot Repeating', price: 18421.05, unit: '1 BOX', subtitle: 'Net: ₹3,500.00'),
        Product(id: 'RC-057', name: '10*10 Multi Colour', category: 'Sky Shot Repeating', price: 15263.16, unit: '1 BOX', subtitle: 'Net: ₹2,900.00'),
        Product(id: 'RC-058', name: '10*10 Multi Colour Crackling', category: 'Sky Shot Repeating', price: 18421.05, unit: '1 BOX', subtitle: 'Net: ₹3,500.00'),
        Product(id: 'RC-059', name: '12 Shot Crackling Skyway', category: 'Sky Shot Repeating', price: 947.37, unit: '1 BOX', subtitle: 'Net: ₹180.00'),
        Product(id: 'RC-060', name: '12 Shot Colour Rider', category: 'Sky Shot Repeating', price: 842.11, unit: '1 BOX', subtitle: 'Net: ₹160.00'),

        // ==========================================
        // 9. SKY SHOT PACK (81% Discount)
        // ==========================================
        Product(id: 'RC-061', name: 'Chotta Fancy (Single)', category: 'Sky Shot Pack', price: 263.16, unit: '1 BOX', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-062', name: 'Chotta Fancy (3 Pieces)', category: 'Sky Shot Pack', price: 1052.63, unit: '1 BOX', subtitle: 'Net: ₹200.00'),
        Product(id: 'RC-063', name: '2 Single', category: 'Sky Shot Pack', price: 526.32, unit: '1 BOX', subtitle: 'Net: ₹100.00'),
        Product(id: 'RC-064', name: '3 1/2 Single', category: 'Sky Shot Pack', price: 1473.68, unit: '1 BOX', subtitle: 'Net: ₹450.00'),
        Product(id: 'RC-065', name: '3 1/2 Fancy (Nayagara Fall)', category: 'Sky Shot Pack', price: 1700.00, unit: '1 BOX', subtitle: 'Net: ₹560.00'),
        Product(id: 'RC-066', name: '4 1/2 Single', category: 'Sky Shot Pack', price: 2105.26, unit: '1 BOX', subtitle: 'Net: ₹400.00'),
        Product(id: 'RC-067', name: '4 1/2 Single Long', category: 'Sky Shot Pack', price: 2368.42, unit: '1 BOX', subtitle: 'Net: ₹450.00'),
        Product(id: 'RC-068', name: '4 1/2 Double', category: 'Sky Shot Pack', price: 4473.68, unit: '1 BOX', subtitle: 'Net: ₹850.00'),
        Product(id: 'RC-069', name: '5 1/2 Single', category: 'Sky Shot Pack', price: 2894.74, unit: '1 BOX', subtitle: 'Net: ₹550.00'),
        Product(id: 'RC-070', name: '5 1/2 Double', category: 'Sky Shot Pack', price: 3157.89, unit: '1 BOX', subtitle: 'Net: ₹600.00'),
        Product(id: 'RC-071', name: '6 1/2 Double', category: 'Sky Shot Pack', price: 6578.95, unit: '1 BOX', subtitle: 'Net: ₹1,250.00'),

        // ==========================================
        // 10. SPARKLERS (81% Discount)
        // ==========================================
        Product(id: 'RC-072', name: '7 CM Electric', category: 'Sparklers', price: 52.63, unit: '1 BOX', subtitle: 'Net: ₹10.00'),
        Product(id: 'RC-073', name: '7 CM Colour', category: 'Sparklers', price: 78.95, unit: '1 BOX', subtitle: 'Net: ₹15.00'),
        Product(id: 'RC-074', name: '7 CM Green', category: 'Sparklers', price: 105.26, unit: '1 BOX', subtitle: 'Net: ₹20.00'),
        Product(id: 'RC-075', name: '7 CM Red', category: 'Sparklers', price: 105.26, unit: '1 BOX', subtitle: 'Net: ₹20.00'),
        Product(id: 'RC-076', name: '10 CM Electric', category: 'Sparklers', price: 157.89, unit: '1 BOX', subtitle: 'Net: ₹30.00'),
        Product(id: 'RC-077', name: '10 CM Colour', category: 'Sparklers', price: 157.89, unit: '1 BOX', subtitle: 'Net: ₹30.00'),
        Product(id: 'RC-078', name: '10 CM Green', category: 'Sparklers', price: 157.89, unit: '1 BOX', subtitle: 'Net: ₹30.00'),
        Product(id: 'RC-079', name: '10 CM Red', category: 'Sparklers', price: 157.89, unit: '1 BOX', subtitle: 'Net: ₹30.00'),
        Product(id: 'RC-080', name: '12 CM Electric', category: 'Sparklers', price: 210.53, unit: '1 BOX', subtitle: 'Net: ₹40.00'),
        Product(id: 'RC-081', name: '12 CM Colour', category: 'Sparklers', price: 210.53, unit: '1 BOX', subtitle: 'Net: ₹40.00'),
        Product(id: 'RC-082', name: '12 CM Green', category: 'Sparklers', price: 210.53, unit: '1 BOX', subtitle: 'Net: ₹40.00'),
        Product(id: 'RC-083', name: '12 CM Red', category: 'Sparklers', price: 210.53, unit: '1 BOX', subtitle: 'Net: ₹40.00'),
        Product(id: 'RC-084', name: '15 CM Electric', category: 'Sparklers', price: 263.16, unit: '1 BOX', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-085', name: '15 CM Colour', category: 'Sparklers', price: 263.16, unit: '1 BOX', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-086', name: '15 CM Green', category: 'Sparklers', price: 263.16, unit: '1 BOX', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-087', name: '15 CM Red', category: 'Sparklers', price: 263.16, unit: '1 BOX', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-088', name: '30 CM Electric', category: 'Sparklers', price: 263.16, unit: '1 BOX', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-089', name: '30 CM Colour', category: 'Sparklers', price: 263.16, unit: '1 BOX', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-090', name: '30 CM Green', category: 'Sparklers', price: 263.16, unit: '1 BOX', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-091', name: '30 CM Red', category: 'Sparklers', price: 263.16, unit: '1 BOX', subtitle: 'Net: ₹50.00'),
        Product(id: 'RC-092', name: '50 CM Electric', category: 'Sparklers', price: 1052.63, unit: '1 BOX', subtitle: 'Net: ₹200.00'),
        Product(id: 'RC-093', name: '50 CM Colour', category: 'Sparklers', price: 1315.79, unit: '1 BOX', subtitle: 'Net: ₹250.00'),
        Product(id: 'RC-094', name: '50 CM Rotating', category: 'Sparklers', price: 1578.95, unit: '1 BOX', subtitle: 'Net: ₹300.00'),

        // ==========================================
        // 11. TWINKLING STARS (81% Discount)
        // ==========================================
        Product(id: 'RC-095', name: '1/2 Twinkling Star', category: 'Twinkling Stars', price: 157.89, unit: '1 BOX', subtitle: 'Net: ₹30.00'),
        Product(id: 'RC-096', name: '4 1/2 Twinkling Star', category: 'Twinkling Stars', price: 368.42, unit: '1 BOX', subtitle: 'Net: ₹70.00'),

        // ==========================================
        // 12. MATCH BOX (81% Discount)
        // ==========================================
        Product(id: 'RC-097', name: 'Match Box Dora', category: 'Match Box', price: 210.53, unit: '1 BOX', subtitle: 'Net: ₹40.00'),
        Product(id: 'RC-098', name: 'Match Box Super Dlx', category: 'Match Box', price: 421.05, unit: '1 BOX', subtitle: 'Net: ₹80.00'),
        Product(id: 'RC-099', name: 'Match Box Pokeman', category: 'Match Box', price: 634.58, unit: '1 BOX', subtitle: 'Net: ₹120.00'),
        Product(id: 'RC-100', name: 'Match Box Royal Mega', category: 'Match Box', price: 1052.63, unit: '1 BOX', subtitle: 'Net: ₹200.00'),

        // ==========================================
        // 13. GIFT BOX (81% Discount)
        // ==========================================
        Product(id: 'RC-101', name: '20 Item Gift Box', category: 'Gift Box', price: 1578.95, unit: '1 BOX', subtitle: 'Net: ₹300.00'),
        Product(id: 'RC-102', name: '30 Item Gift Box', category: 'Gift Box', price: 2368.42, unit: '1 BOX', subtitle: 'Net: ₹450.00'),
        Product(id: 'RC-103', name: '40 Item Gift Box', category: 'Gift Box', price: 3052.63, unit: '1 BOX', subtitle: 'Net: ₹580.00'),

        // ==========================================
        // 14. FAMILY PACK (81% Discount)
        // ==========================================
        Product(id: 'RC-104', name: '3000 Family Pack', category: 'Family Pack', price: 15789.47, unit: '1 BOX', subtitle: 'Net: ₹3,000.00'),
        Product(id: 'RC-105', name: '5000 Family Pack', category: 'Family Pack', price: 26315.79, unit: '1 BOX', subtitle: 'Net: ₹5,000.00'),
        Product(id: 'RC-106', name: '7000 Family Pack', category: 'Family Pack', price: 36842.11, unit: '1 BOX', subtitle: 'Net: ₹7,000.00'),
        Product(id: 'RC-107', name: '10000 Family Pack', category: 'Family Pack', price: 52631.58, unit: '1 BOX', subtitle: 'Net: ₹10,000.00'),

        // ==========================================
        // 15. 2026 SERIES NEW ARRIVAL (81% Discount)
        // ==========================================
        Product(id: 'RC-108', name: 'Lucky Money (3 Pcs)', category: '2026 Series New Arrival', price: 1000.00, unit: '1 BOX', subtitle: 'Net: ₹190.00'),
        Product(id: 'RC-109', name: 'Sound Party (3 Pcs)', category: '2026 Series New Arrival', price: 2052.63, unit: '1 BOX', subtitle: 'Net: ₹390.00'),
        Product(id: 'RC-110', name: 'Ola Vedi (25 Pcs)', category: '2026 Series New Arrival', price: 1000.00, unit: '1 BOX', subtitle: 'Net: ₹190.00'),
        Product(id: 'RC-111', name: 'Popcorn Pencil (5 Pcs)', category: '2026 Series New Arrival', price: 1421.05, unit: '1 BOX', subtitle: 'Net: ₹270.00'),
        Product(id: 'RC-112', name: 'Water Falls Pencil (5 Pcs)', category: '2026 Series New Arrival', price: 1421.05, unit: '1 BOX', subtitle: 'Net: ₹270.00'),
        Product(id: 'RC-113', name: 'Hunter 007 (5 Pcs)', category: '2026 Series New Arrival', price: 1421.05, unit: '1 BOX', subtitle: 'Net: ₹270.00'),
        Product(id: 'RC-114', name: 'Kalashinkov (2 Pcs)', category: '2026 Series New Arrival', price: 1421.05, unit: '1 BOX', subtitle: 'Net: ₹270.00'),
        Product(id: 'RC-115', name: 'Red, Green Crackling Gold Peacock', category: '2026 Series New Arrival', price: 1315.79, unit: '1 BOX', subtitle: 'Net: ₹250.00'),
        Product(id: 'RC-116', name: 'Kids Star War (2 Pcs)', category: '2026 Series New Arrival', price: 1315.79, unit: '1 BOX', subtitle: 'Net: ₹250.00'),
        Product(id: 'RC-117', name: '6" Aqua Queen', category: '2026 Series New Arrival', price: 1421.05, unit: '1 BOX', subtitle: 'Net: ₹270.00'),
        Product(id: 'RC-118', name: '6" Monster TN67', category: '2026 Series New Arrival', price: 1421.05, unit: '1 BOX', subtitle: 'Net: ₹270.00'),
        Product(id: 'RC-119', name: '6" Rolex (RX100)', category: '2026 Series New Arrival', price: 1421.05, unit: '1 BOX', subtitle: 'Net: ₹270.00'),
        Product(id: 'RC-120', name: 'Mowgli (5 Pcs)', category: '2026 Series New Arrival', price: 947.37, unit: '1 BOX', subtitle: 'Net: ₹180.00'),
        Product(id: 'RC-121', name: 'Mankatha (5 Pcs)', category: '2026 Series New Arrival', price: 1421.05, unit: '1 BOX', subtitle: 'Net: ₹270.00'),
        Product(id: 'RC-122', name: 'Super Singer (5 Pcs)', category: '2026 Series New Arrival', price: 1315.79, unit: '1 BOX', subtitle: 'Net: ₹250.00'),
        Product(id: 'RC-123', name: 'Badaa Peacock', category: '2026 Series New Arrival', price: 2368.42, unit: '1 BOX', subtitle: 'Net: ₹450.00'),
        Product(id: 'RC-124', name: '100" W-Power (3 Pcs)', category: '2026 Series New Arrival', price: 1157.89, unit: '1 BOX', subtitle: 'Net: ₹220.00'),
        Product(id: 'RC-125', name: 'The Leader (3 Pcs)', category: '2026 Series New Arrival', price: 1368.42, unit: '1 BOX', subtitle: 'Net: ₹260.00'),
        Product(id: 'RC-126', name: 'Jigarthanda (3 Pcs)', category: '2026 Series New Arrival', price: 1315.79, unit: '1 BOX', subtitle: 'Net: ₹250.00'),
        Product(id: 'RC-127', name: 'Thunder Coconut Crackling (3Pcs)', category: '2026 Series New Arrival', price: 1789.47, unit: '1 BOX', subtitle: 'Net: ₹340.00'),
        Product(id: 'RC-128', name: 'Fire & Feather (6 Pcs)', category: '2026 Series New Arrival', price: 894.74, unit: '1 BOX', subtitle: 'Net: ₹170.00'),
        Product(id: 'RC-129', name: 'Nebula (5 Pcs)', category: '2026 Series New Arrival', price: 842.11, unit: '1 BOX', subtitle: 'Net: ₹160.00'),
        Product(id: 'RC-130', name: 'Golden Sparrow (5 Pcs)', category: '2026 Series New Arrival', price: 842.11, unit: '1 BOX', subtitle: 'Net: ₹160.00'),
        Product(id: 'RC-131', name: 'Dragon Stay (5 Pcs) Multicolor', category: '2026 Series New Arrival', price: 1263.16, unit: '1 BOX', subtitle: 'Net: ₹240.00'),
        Product(id: 'RC-132', name: 'MC Laser (3 Pcs)', category: '2026 Series New Arrival', price: 1473.68, unit: '1 BOX', subtitle: 'Net: ₹280.00'),
        Product(id: 'RC-133', name: 'Formula 7 (3 Pcs) Multicolour', category: '2026 Series New Arrival', price: 1526.32, unit: '1 BOX', subtitle: 'Net: ₹290.00'),
        Product(id: 'RC-134', name: 'Penta Race (5 Pcs) Multicolour', category: '2026 Series New Arrival', price: 1210.53, unit: '1 BOX', subtitle: 'Net: ₹230.00'),
        Product(id: 'RC-135', name: 'Rapid Burst (5 Pcs) Multicolour', category: '2026 Series New Arrival', price: 1315.79, unit: '1 BOX', subtitle: 'Net: ₹250.00'),
        Product(id: 'RC-154', name: '1/4 KGS PAPER BOMB', category: 'Naattu Vedi', price: 394.74, unit: '1Pies', subtitle: 'Net: ₹75.00'),
        Product(id: 'RC-155', name: '1/2 kgs Paper bomb', category: 'Naattu Vedi', price: 789.47, unit: '1Pies', subtitle: 'Net: ₹150.00'),
        Product(id: 'RC-156', name: '1 Kgs paper bomb', category: 'Naattu Vedi', price: 1578.95, unit: '1Pies', subtitle: 'Net: ₹300.00'),
        Product(id: 'RC-282', name: "10'ADIYAI 10 Pie", category: 'Sky Shot Pack', price: 2368.42, unit: '1BOX', subtitle: 'Net: ₹450.00'),
      ];
}
