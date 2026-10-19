import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  Database? _db;

  static const List<Map<String, dynamic>> _allLocations = [
    // --- 1. KEY TRANSPORT HUBS & TERMINALS ---
    {
      'name': 'Bhopal Central Railway Station (BPL)',
      'latitude': 23.2672,
      'longitude': 77.4130,
      'category': 'station'
    },
    {
      'name': 'Rani Kamlapati Railway Station (RKMP)',
      'latitude': 23.2186,
      'longitude': 77.4377,
      'category': 'station'
    },
    {
      'name': 'Kushabhau Thakre ISBT (Inter State Bus Terminal)',
      'latitude': 23.2382,
      'longitude': 77.4485,
      'category': 'station'
    },
    {
      'name': 'Raja Bhoj International Airport',
      'latitude': 23.2875,
      'longitude': 77.3378,
      'category': 'airport'
    },
    {
      'name': 'Sant Hirdaram Nagar Railway Station (Bairagarh)',
      'latitude': 23.2738,
      'longitude': 77.3337,
      'category': 'station'
    },
    {
      'name': 'Nishatpura Railway Station',
      'latitude': 23.2866,
      'longitude': 77.4314,
      'category': 'station'
    },
    {
      'name': 'Misrod Railway Station',
      'latitude': 23.1608,
      'longitude': 77.4683,
      'category': 'station'
    },
    {
      'name': 'Nadra Bus Stand',
      'latitude': 23.2645,
      'longitude': 77.4105,
      'category': 'station'
    },
    {
      'name': 'Halalpura Bus Stand',
      'latitude': 23.2735,
      'longitude': 77.3520,
      'category': 'station'
    },

    // --- 2. MAJOR LOCALITIES & RESIDENTIAL NEIGHBORHOODS ---
    {
      'name': 'MP Nagar (Maharana Pratap Nagar)',
      'latitude': 23.2332,
      'longitude': 77.4343,
      'category': 'locality'
    },
    {
      'name': 'Arera Colony (E1-E7)',
      'latitude': 23.2112,
      'longitude': 77.4329,
      'category': 'locality'
    },
    {
      'name': 'Kolar Road',
      'latitude': 23.1829,
      'longitude': 77.4177,
      'category': 'locality'
    },
    {
      'name': 'Shahpura',
      'latitude': 23.2000,
      'longitude': 77.4167,
      'category': 'locality'
    },
    {
      'name': 'New Market',
      'latitude': 23.2341,
      'longitude': 77.4018,
      'category': 'locality'
    },
    {
      'name': 'TT Nagar (Tatya Tope Nagar)',
      'latitude': 23.2333,
      'longitude': 77.3960,
      'category': 'locality'
    },
    {
      'name': 'BHEL Township',
      'latitude': 23.2401,
      'longitude': 77.4645,
      'category': 'locality'
    },
    {
      'name': 'Govindpura Industrial Area',
      'latitude': 23.2583,
      'longitude': 77.4497,
      'category': 'locality'
    },
    {
      'name': 'Indrapuri',
      'latitude': 23.2519,
      'longitude': 77.4619,
      'category': 'locality'
    },
    {
      'name': 'Piplani',
      'latitude': 23.2469,
      'longitude': 77.4686,
      'category': 'locality'
    },
    {
      'name': 'Ayodhya Nagar & Bypass',
      'latitude': 23.2803,
      'longitude': 77.4686,
      'category': 'locality'
    },
    {
      'name': 'Anand Nagar',
      'latitude': 23.2500,
      'longitude': 77.4900,
      'category': 'locality'
    },
    {
      'name': 'Koh-e-Fiza',
      'latitude': 23.2653,
      'longitude': 77.3756,
      'category': 'locality'
    },
    {
      'name': 'Lalghati',
      'latitude': 23.2773,
      'longitude': 77.3640,
      'category': 'locality'
    },
    {
      'name': 'Bairagarh (Sant Hirdaram Nagar)',
      'latitude': 23.2738,
      'longitude': 77.3337,
      'category': 'locality'
    },
    {
      'name': 'Karond',
      'latitude': 23.2956,
      'longitude': 77.4003,
      'category': 'locality'
    },
    {
      'name': 'Bhanpur',
      'latitude': 23.2992,
      'longitude': 77.4159,
      'category': 'locality'
    },
    {
      'name': 'Gandhinagar',
      'latitude': 23.3072,
      'longitude': 77.3585,
      'category': 'locality'
    },
    {
      'name': 'Shahjahanabad',
      'latitude': 23.2721,
      'longitude': 77.3970,
      'category': 'locality'
    },
    {
      'name': 'Jahangirabad',
      'latitude': 23.2486,
      'longitude': 77.4153,
      'category': 'locality'
    },
    {
      'name': 'Ashoka Garden',
      'latitude': 23.2558,
      'longitude': 77.4333,
      'category': 'locality'
    },
    {
      'name': 'Chunabhatti',
      'latitude': 23.2009,
      'longitude': 77.4138,
      'category': 'locality'
    },
    {
      'name': 'Gulmohar Colony',
      'latitude': 23.1809,
      'longitude': 77.4386,
      'category': 'locality'
    },
    {
      'name': 'Trilanga',
      'latitude': 23.1918,
      'longitude': 77.4327,
      'category': 'locality'
    },
    {
      'name': 'Bawadiya Kalan',
      'latitude': 23.1824,
      'longitude': 77.4386,
      'category': 'locality'
    },
    {
      'name': 'Saket Nagar',
      'latitude': 23.2153,
      'longitude': 77.4601,
      'category': 'locality'
    },
    {
      'name': 'Shakti Nagar',
      'latitude': 23.2152,
      'longitude': 77.4526,
      'category': 'locality'
    },
    {
      'name': 'Alkapuri',
      'latitude': 23.2131,
      'longitude': 77.4547,
      'category': 'locality'
    },
    {
      'name': 'Barkheda & Barkheda Pathani',
      'latitude': 23.2192,
      'longitude': 77.4678,
      'category': 'locality'
    },
    {
      'name': 'Bagh Sewaniya',
      'latitude': 23.1928,
      'longitude': 77.4475,
      'category': 'locality'
    },
    {
      'name': 'Danish Kunj',
      'latitude': 23.1892,
      'longitude': 77.4258,
      'category': 'locality'
    },
    {
      'name': 'Neelbad',
      'latitude': 23.1934,
      'longitude': 77.3431,
      'category': 'locality'
    },
    {
      'name': 'Ratibad',
      'latitude': 23.1855,
      'longitude': 77.3316,
      'category': 'locality'
    },
    {
      'name': 'Misrod',
      'latitude': 23.1608,
      'longitude': 77.4683,
      'category': 'locality'
    },
    {
      'name': 'Mandideep Industrial Suburb',
      'latitude': 23.0944,
      'longitude': 77.5181,
      'category': 'locality'
    },
    {
      'name': 'Shyamala Hills',
      'latitude': 23.2420,
      'longitude': 77.3850,
      'category': 'locality'
    },
    {
      'name': 'Idgah Hills',
      'latitude': 23.2700,
      'longitude': 77.3850,
      'category': 'locality'
    },
    {
      'name': 'Arera Hills',
      'latitude': 23.2380,
      'longitude': 77.4180,
      'category': 'locality'
    },
    {
      'name': 'Tulsi Nagar & Shivaji Nagar',
      'latitude': 23.2280,
      'longitude': 77.4130,
      'category': 'locality'
    },
    {
      'name': 'Char Imli',
      'latitude': 23.2200,
      'longitude': 77.4200,
      'category': 'locality'
    },
    {
      'name': 'Peer Gate (Old City)',
      'latitude': 23.2599,
      'longitude': 77.4024,
      'category': 'locality'
    },
    {
      'name': 'Budhwara',
      'latitude': 23.2524,
      'longitude': 77.4052,
      'category': 'locality'
    },
    {
      'name': 'Chowk Bazaar (Old Bhopal)',
      'latitude': 23.2584,
      'longitude': 77.4032,
      'category': 'shopping'
    },
    {
      'name': 'Berasia Town',
      'latitude': 23.6222,
      'longitude': 77.4312,
      'category': 'locality'
    },
    {
      'name': 'Sehore Outer Corridor',
      'latitude': 23.2000,
      'longitude': 77.0800,
      'category': 'locality'
    },

    // --- 3. LAKES, DAMS, PARKS & ECOTOURISM ---
    {
      'name': 'Upper Lake (Bada Talab / Bhojtal)',
      'latitude': 23.2500,
      'longitude': 77.3500,
      'category': 'lake'
    },
    {
      'name': 'Lower Lake (Chhota Talab)',
      'latitude': 23.2425,
      'longitude': 77.4060,
      'category': 'lake'
    },
    {
      'name': 'Shahpura Lake',
      'latitude': 23.1970,
      'longitude': 77.4190,
      'category': 'lake'
    },
    {
      'name': 'Boat Club Bhopal',
      'latitude': 23.2429,
      'longitude': 77.3812,
      'category': 'park'
    },
    {
      'name': 'Van Vihar National Park',
      'latitude': 23.2285,
      'longitude': 77.3685,
      'category': 'park'
    },
    {
      'name': 'Sair Sapata Tourism Complex',
      'latitude': 23.2166,
      'longitude': 77.3824,
      'category': 'park'
    },
    {
      'name': 'Kerwa Dam',
      'latitude': 23.1674,
      'longitude': 77.3727,
      'category': 'attraction'
    },
    {
      'name': 'Kaliasot Dam',
      'latitude': 23.1917,
      'longitude': 77.4127,
      'category': 'attraction'
    },
    {
      'name': 'Bhadbhada Dam',
      'latitude': 23.2050,
      'longitude': 77.3740,
      'category': 'attraction'
    },
    {
      'name': 'Halali Dam & Reservoir',
      'latitude': 23.4900,
      'longitude': 77.5100,
      'category': 'attraction'
    },
    {
      'name': 'VIP Road Lake Promenade',
      'latitude': 23.2589,
      'longitude': 77.4125,
      'category': 'attraction'
    },
    {
      'name': 'Kamla Park',
      'latitude': 23.2547,
      'longitude': 77.4029,
      'category': 'park'
    },
    {
      'name': 'Ekant Park',
      'latitude': 23.2156,
      'longitude': 77.4217,
      'category': 'park'
    },
    {
      'name': 'Mayur Park',
      'latitude': 23.2312,
      'longitude': 77.4135,
      'category': 'park'
    },
    {
      'name': 'Chinar Park',
      'latitude': 23.2450,
      'longitude': 77.4620,
      'category': 'park'
    },
    {
      'name': 'Sheetal Das Ki Bagiya',
      'latitude': 23.2480,
      'longitude': 77.3910,
      'category': 'park'
    },
    {
      'name': 'Motia Park',
      'latitude': 23.2705,
      'longitude': 77.4010,
      'category': 'park'
    },
    {
      'name': 'Samardha Ecotourism Spot',
      'latitude': 23.3322,
      'longitude': 77.5827,
      'category': 'park'
    },
    {
      'name': 'Samasgarh Ancient Temple & Forest',
      'latitude': 23.1209,
      'longitude': 77.3296,
      'category': 'attraction'
    },

    // --- 4. HERITAGE, FORTS, MUSEUMS & SPIRITUAL LANDMARKS ---
    {
      'name': 'Taj-ul-Masajid',
      'latitude': 23.2642,
      'longitude': 77.3932,
      'category': 'attraction'
    },
    {
      'name': 'Moti Masjid',
      'latitude': 23.2557,
      'longitude': 77.3989,
      'category': 'attraction'
    },
    {
      'name': 'Gohar Mahal',
      'latitude': 23.2549,
      'longitude': 77.3979,
      'category': 'attraction'
    },
    {
      'name': 'Shaukat Mahal & Sadar Manzil',
      'latitude': 23.2568,
      'longitude': 77.4019,
      'category': 'attraction'
    },
    {
      'name': 'Iqbal Maidan',
      'latitude': 23.2560,
      'longitude': 77.3980,
      'category': 'attraction'
    },
    {
      'name': 'Bharat Bhavan',
      'latitude': 23.2435,
      'longitude': 77.3878,
      'category': 'museum'
    },
    {
      'name': 'Indira Gandhi Rashtriya Manav Sangrahalaya (IGRMS)',
      'latitude': 23.2329,
      'longitude': 77.3788,
      'category': 'museum'
    },
    {
      'name': 'Madhya Pradesh Tribal Museum',
      'latitude': 23.2278,
      'longitude': 77.3892,
      'category': 'museum'
    },
    {
      'name': 'State Museum Bhopal',
      'latitude': 23.2312,
      'longitude': 77.3888,
      'category': 'museum'
    },
    {
      'name': 'Regional Science Centre (RSC)',
      'latitude': 23.2599,
      'longitude': 77.4126,
      'category': 'museum'
    },
    {
      'name': 'Birla Mandir (Lakshmi Narayan Temple)',
      'latitude': 23.2383,
      'longitude': 77.4086,
      'category': 'attraction'
    },
    {
      'name': 'Manuabhan ki Tekri (Mahavir Giri)',
      'latitude': 23.2870,
      'longitude': 77.3750,
      'category': 'attraction'
    },
    {
      'name': 'Gufa Mandir Lalghati',
      'latitude': 23.2763,
      'longitude': 77.3761,
      'category': 'attraction'
    },
    {
      'name': 'Curfew Wali Mata Mandir',
      'latitude': 23.2575,
      'longitude': 77.4010,
      'category': 'attraction'
    },
    {
      'name': 'Khatlapura Temple',
      'latitude': 23.2450,
      'longitude': 77.4080,
      'category': 'attraction'
    },
    {
      'name': 'Islamnagar Fort (Jagdishpur Palace)',
      'latitude': 23.3547,
      'longitude': 77.4171,
      'category': 'attraction'
    },
    {
      'name': 'Bhojeshwar Temple (Bhojpur)',
      'latitude': 23.1003,
      'longitude': 77.5797,
      'category': 'attraction'
    },
    {
      'name': 'Bhimbetka Rock Shelters (UNESCO Site)',
      'latitude': 22.9384,
      'longitude': 77.6131,
      'category': 'attraction'
    },
    {
      'name': 'Sanchi Stupa (UNESCO World Heritage Site)',
      'latitude': 23.4873,
      'longitude': 77.7418,
      'category': 'attraction'
    },
    {
      'name': 'Raisen Fort',
      'latitude': 23.3305,
      'longitude': 77.7839,
      'category': 'attraction'
    },

    // --- 5. HOSPITALS & HEALTHCARE CENTERS ---
    {
      'name': 'AIIMS Bhopal (All India Institute of Medical Sciences)',
      'latitude': 23.2065,
      'longitude': 77.4608,
      'category': 'hospital'
    },
    {
      'name': 'Hamidia Hospital & Gandhi Medical College',
      'latitude': 23.2625,
      'longitude': 77.3965,
      'category': 'hospital'
    },
    {
      'name': 'Bhopal Memorial Hospital & Research Centre (BMHRC)',
      'latitude': 23.2780,
      'longitude': 77.4162,
      'category': 'hospital'
    },
    {
      'name': 'Bansal Hospital Shahpura',
      'latitude': 23.1970,
      'longitude': 77.4290,
      'category': 'hospital'
    },
    {
      'name': 'Chirayu Medical College & Hospital',
      'latitude': 23.2683,
      'longitude': 77.3075,
      'category': 'hospital'
    },
    {
      'name': 'JP Hospital (Jai Prakash District Hospital)',
      'latitude': 23.2299,
      'longitude': 77.4168,
      'category': 'hospital'
    },
    {
      'name': 'Kasturba Hospital BHEL',
      'latitude': 23.2235,
      'longitude': 77.4482,
      'category': 'hospital'
    },
    {
      'name': 'Narmada Trauma Centre Arera Colony',
      'latitude': 23.2139,
      'longitude': 77.4300,
      'category': 'hospital'
    },
    {
      'name': 'LBS Hospital Bhopal',
      'latitude': 23.2250,
      'longitude': 77.4180,
      'category': 'hospital'
    },
    {
      'name': 'Siddhanta Red Cross Hospital',
      'latitude': 23.2320,
      'longitude': 77.4110,
      'category': 'hospital'
    },
    {
      'name': 'Noble Multi Speciality Hospital',
      'latitude': 23.1890,
      'longitude': 77.4580,
      'category': 'hospital'
    },

    // --- 6. UNIVERSITIES & MAJOR COLLEGES ---
    {
      'name': 'MANIT Bhopal (Maulana Azad National Institute of Technology)',
      'latitude': 23.2167,
      'longitude': 77.4069,
      'category': 'college'
    },
    {
      'name': 'IISER Bhopal (Indian Institute of Science Education & Research)',
      'latitude': 23.2842,
      'longitude': 77.2764,
      'category': 'college'
    },
    {
      'name': 'National Law Institute University (NLIU)',
      'latitude': 23.1871,
      'longitude': 77.3633,
      'category': 'college'
    },
    {
      'name': 'IIIT Bhopal (Indian Institute of Information Technology)',
      'latitude': 23.2170,
      'longitude': 77.4080,
      'category': 'college'
    },
    {
      'name': 'RGPV (Rajiv Gandhi Proudyogiki Vishwavidyalaya)',
      'latitude': 23.3122,
      'longitude': 77.3619,
      'category': 'college'
    },
    {
      'name': 'Barkatullah University',
      'latitude': 23.1945,
      'longitude': 77.4475,
      'category': 'college'
    },
    {
      'name': 'SPA Bhopal (School of Planning and Architecture)',
      'latitude': 23.2850,
      'longitude': 77.2770,
      'category': 'college'
    },
    {
      'name': 'NID MP (National Institute of Design)',
      'latitude': 23.3210,
      'longitude': 77.3480,
      'category': 'college'
    },
    {
      'name': 'LNCT Group of Colleges (Raisen Road)',
      'latitude': 23.2370,
      'longitude': 77.4920,
      'category': 'college'
    },
    {
      'name': 'TIT Group of Institutions (Anand Nagar)',
      'latitude': 23.2520,
      'longitude': 77.4940,
      'category': 'college'
    },
    {
      'name': 'People\'s University',
      'latitude': 23.2810,
      'longitude': 77.4450,
      'category': 'college'
    },
    {
      'name': 'Jagran Lakecity University (Mugaliya Chhap)',
      'latitude': 23.1650,
      'longitude': 77.3420,
      'category': 'college'
    },
    {
      'name': 'RKDF University',
      'latitude': 23.1790,
      'longitude': 77.4640,
      'category': 'college'
    },
    {
      'name': 'BSSS College (Bhopal School of Social Sciences)',
      'latitude': 23.2080,
      'longitude': 77.4330,
      'category': 'college'
    },

    // --- 7. SHOPPING MALLS & MAJOR COMMERCIAL CENTERS ---
    {
      'name': 'DB City Mall',
      'latitude': 23.2326,
      'longitude': 77.4300,
      'category': 'mall'
    },
    {
      'name': 'Aashima Anupama Mall (Hoshangabad Rd)',
      'latitude': 23.1810,
      'longitude': 77.4567,
      'category': 'mall'
    },
    {
      'name': 'Aura Mall (Trilanga)',
      'latitude': 23.2163,
      'longitude': 77.4293,
      'category': 'mall'
    },
    {
      'name': 'Capital Mall / C21 Mall (Misrod)',
      'latitude': 23.1642,
      'longitude': 77.4688,
      'category': 'mall'
    },
    {
      'name': 'People\'s Mall (Bhanpur)',
      'latitude': 23.2795,
      'longitude': 77.4431,
      'category': 'mall'
    },
    {
      'name': 'Vishal Mega Mart MP Nagar',
      'latitude': 23.2315,
      'longitude': 77.4330,
      'category': 'shopping'
    },
    {
      'name': '10 No. Market Arera Colony',
      'latitude': 23.2120,
      'longitude': 77.4310,
      'category': 'shopping'
    },
    {
      'name': 'Bittan Market Haat Ground',
      'latitude': 23.2090,
      'longitude': 77.4280,
      'category': 'shopping'
    },
    {
      'name': '6 No. Market Shivaji Nagar',
      'latitude': 23.2240,
      'longitude': 77.4170,
      'category': 'shopping'
    },
    {
      'name': 'Bairagarh Textile Cloth Market',
      'latitude': 23.2740,
      'longitude': 77.3360,
      'category': 'shopping'
    },

    // --- 8. GOVERNMENT SECRETARIATS, COURTS & STADIUMS ---
    {
      'name': 'Vallabh Bhawan (MP State Secretariat)',
      'latitude': 23.2359,
      'longitude': 77.4181,
      'category': 'government'
    },
    {
      'name': 'Satpura Bhawan',
      'latitude': 23.2345,
      'longitude': 77.4208,
      'category': 'government'
    },
    {
      'name': 'Vindhyachal Bhawan',
      'latitude': 23.2377,
      'longitude': 77.4088,
      'category': 'government'
    },
    {
      'name': 'District and Sessions Court Bhopal',
      'latitude': 23.2390,
      'longitude': 77.4256,
      'category': 'government'
    },
    {
      'name': 'Police Headquarters (PHQ) Bhopal',
      'latitude': 23.2450,
      'longitude': 77.4150,
      'category': 'police'
    },
    {
      'name': 'TT Nagar Stadium (Tatya Tope Sports Complex)',
      'latitude': 23.2311,
      'longitude': 77.3997,
      'category': 'stadium'
    },
    {
      'name': 'Aishbagh Stadium (Hockey Stadium)',
      'latitude': 23.2557,
      'longitude': 77.4205,
      'category': 'stadium'
    },
    {
      'name': 'Motilal Nehru Stadium (Lal Parade Ground)',
      'latitude': 23.2500,
      'longitude': 77.4200,
      'category': 'stadium'
    },
    {
      'name': 'Major Dhyanchand Stadium',
      'latitude': 23.2380,
      'longitude': 77.4050,
      'category': 'stadium'
    },

    // --- 9. FUEL / GAS STATIONS ---
    {
      'name': 'HP Fuel Station - MP Nagar Zone 1',
      'latitude': 23.2320,
      'longitude': 77.4300,
      'category': 'gas_station'
    },
    {
      'name': 'IndianOil Petrol Pump - Arera Hills',
      'latitude': 23.2395,
      'longitude': 77.4180,
      'category': 'gas_station'
    },
    {
      'name': 'Bharat Petroleum - Hoshangabad Rd',
      'latitude': 23.2045,
      'longitude': 77.4480,
      'category': 'gas_station'
    },
    {
      'name': 'HP Petrol Pump - Kolar Road',
      'latitude': 23.1800,
      'longitude': 77.4200,
      'category': 'gas_station'
    },
    {
      'name': 'IndianOil Station - Lalghati Chauraha',
      'latitude': 23.2760,
      'longitude': 77.3660,
      'category': 'gas_station'
    },
    {
      'name': 'CNG Filling Station - Govindpura',
      'latitude': 23.2530,
      'longitude': 77.4520,
      'category': 'gas_station'
    },

    // --- 10. FAMOUS FOOD, RESTAURANTS & CAFES ---
    {
      'name': 'Indian Coffee House - New Market',
      'latitude': 23.2345,
      'longitude': 77.4025,
      'category': 'cafe'
    },
    {
      'name': 'Manohar Dairy & Restaurant (MP Nagar)',
      'latitude': 23.2330,
      'longitude': 77.4345,
      'category': 'restaurant'
    },
    {
      'name': 'Manohar Dairy & Restaurant (Hamidia Rd)',
      'latitude': 23.2650,
      'longitude': 77.4110,
      'category': 'restaurant'
    },
    {
      'name': 'Wind & Waves Restaurant (Lake View)',
      'latitude': 23.2420,
      'longitude': 77.3820,
      'category': 'restaurant'
    },
    {
      'name': 'Bapu Ki Kutia - TT Nagar',
      'latitude': 23.2330,
      'longitude': 77.3990,
      'category': 'restaurant'
    },
    {
      'name': 'Hakeem Hotel - MP Nagar',
      'latitude': 23.2340,
      'longitude': 77.4330,
      'category': 'restaurant'
    },
    {
      'name': 'Sagar Gaire Fast Food - 10 No. Market',
      'latitude': 23.2125,
      'longitude': 77.4315,
      'category': 'restaurant'
    },
    {
      'name': 'Sagar Gaire Fast Food - 7 No. Stop',
      'latitude': 23.2210,
      'longitude': 77.4240,
      'category': 'restaurant'
    },
    {
      'name': 'Sharma & Vishnu Fast Food - Shahpura',
      'latitude': 23.1990,
      'longitude': 77.4180,
      'category': 'restaurant'
    },
  ];

  static List<Map<String, dynamic>> get fallbackPois => _allLocations;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'offline_gps.db');
    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE poi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            category TEXT
          )
        ''');
        await _seedPois(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS poi');
        await db.execute('''
          CREATE TABLE poi (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            category TEXT
          )
        ''');
        await _seedPois(db);
      },
    );
    return _db!;
  }

  static Future<void> _seedPois(Database db) async {
    for (final poi in _allLocations) {
      await db.insert('poi', poi);
    }
  }

  Future<List<Map<String, dynamic>>> searchPois(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return getAllPois();
    }

    try {
      if (kIsWeb) {
        return _searchInMemory(trimmed);
      }
      final db = await database;
      final results = await db.query(
        'poi',
        where: 'name LIKE ? OR category LIKE ?',
        whereArgs: ['%$trimmed%', '%$trimmed%'],
      );
      if (results.isEmpty) {
        return _searchInMemory(trimmed);
      }
      return results;
    } catch (e) {
      debugPrint('Database query failed, using in-memory fallback: $e');
      return _searchInMemory(trimmed);
    }
  }

  List<Map<String, dynamic>> _searchInMemory(String query) {
    final q = query.toLowerCase();
    return _allLocations.where((p) {
      final name = (p['name'] as String? ?? '').toLowerCase();
      final cat = (p['category'] as String? ?? '').toLowerCase();
      return name.contains(q) || cat.contains(q);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAllPois() async {
    try {
      if (kIsWeb) {
        return List<Map<String, dynamic>>.from(_allLocations);
      }
      final db = await database;
      final results = await db.query('poi');
      if (results.isEmpty) {
        return List<Map<String, dynamic>>.from(_allLocations);
      }
      return results;
    } catch (e) {
      debugPrint('Database getAllPois failed, using in-memory list: $e');
      return List<Map<String, dynamic>>.from(_allLocations);
    }
  }
}
