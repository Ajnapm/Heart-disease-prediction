// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_typeahead/flutter_typeahead.dart';

// class RecommendPage extends StatefulWidget {
//   const RecommendPage({Key? key}) : super(key: key);

//   @override
//   State<RecommendPage> createState() => _RecommendPageState();
// }

// class _RecommendPageState extends State<RecommendPage> {
//   final TextEditingController _districtTextController = TextEditingController();
//   final TextEditingController _locationTextController = TextEditingController();

//   final List<String> _recommendations = [];

//   List<String> _districts = [
//     'Thiruvananthapuram',
//     'Kollam',
//     'Alappuzha',
//     'pathanamthitta',
//     'Kottayam',
//     'Idukki',
//     'Palakkad',
//     'Malappuram',
//     'Kozhikode',
//     'Kannur',
//     'Kasargode',
//     'wayanad',
//     'ernakulam',
//     ''
//   ]; // Sample districts list

//   Map<String, List<String>> _districtLocations = {
//     'Thiruvananthapuram': [
//       'Anayara',
//       'pattom',
//       'vanchiyoor',
//       'kesavadasapuram',
//       'Choozhampala',
//       'Kumarapuram',
//       'venpakal',
//       'ulloor',
//       'manavaud'
//     ],
//     'kollam': [
//       'Mylapore',
//       'paravoor',
//       'Chinnakada',
//       'Anandavalleswaram',
//       'kundara',
//       'kottiyam',
//       'Thirumullavaram',
//       'Nallila',
//       'Karunagapally',
//       'kottarakara'
//     ],
//     'Alappuzha': [
//       'Perunthalmanna',
//       'Chungam',
//       'Thodankulangara',
//       'Thathampally',
//       'Mullackal',
//       'Kannadi',
//       'Kuttapuzha',
//       'Alappuzha',
//       'Chembukkavu'
//     ],
//     'Pathanamthitta': [
//       'Thiruvalla',
//       'Thiruvalla',
//       'Parumala',
//       'Pandalam',
//       'Pathanamthitta',
//       'Kavumbhagom',
//       'Adoor'
//     ],
//     'Kottayam': [
//       'Thellakom',
//       'Gandhinagar',
//       'Medical College Junction',
//       'Anandapuram',
//       'Kanjikuzhy',
//       'Ramapuram',
//       'Kottayam'
//     ],
//     'Idukki': [
//       'Muttom',
//       'Kuttikanam',
//       'Thodupuzha',
//       'Thodupuzha',
//       'Molamattom'
//     ],
//     'Palakkad': [
//       'Chittur',
//       'Koppam',
//       'Fort Maidan',
//       'Koottupatha',
//       'Mannarkkad',
//       'Athani',
//       'Olavakkode'
//     ],
//     'Malappuram': [
//       'Perinthalmanna',
//       'Kottakkal',
//       'Manjeri',
//       'Parappanangadi',
//       'Edappal'
//     ],
//     'Kozhikode': [
//       'Indira Gandhi Road',
//       'Kallai',
//       'Govindapuram',
//       'Mankavu',
//       'East Hill',
//       'Perambra',
//       'East Nadakavu',
//       'Pavangad'
//     ],
//     'kannur': [
//       'Pazhassi Nagar',
//       'Talap',
//       'Sreekandapuram',
//       'South Bazar',
//       'Chala',
//       'Panoor',
//       'Mattannur',
//       'Kadirur',
//       'Thalassery'
//     ],
//     'Kasargode': [
//       'Vidyanagar',
//       'Bank Road',
//       'Kasargode',
//       'Badiyadka',
//       'Muliyar',
//       'Kottappuram',
//       'Mangalpady'
//     ],
//     'Wayanad': [
//       'Kalpetta',
//       'Sultan Bathery',
//       'Pulpally',
//       'South chittor'
//     ],
//     'Ernakulam': [
//       'Aluva',
//       'kakkanad',
//       'kachripady',
//       'edappally'
//     ],
//     'Thrissur': [
//       'Amalanagar',
//       'Guruvayur road'
//     ]
//   }; // Sample location mapping

//   String _selectedDistrict = '';
//   String _selectedLocation = '';

//   void _getRecommendations() async {
//     final location = _selectedLocation;
//     _recommendations.clear();

//     try {
//       final response = await http.post(
//         Uri.parse("http://192.168.236.254:5000/recommend"),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode({"location": location}),
//       );

//       if (response.statusCode!= 200) {
//         setState(() {
//           _recommendations.add('No records found for this location');
//         });
//         return;
//       }

//       final data = json.decode(response.body);
//       final hospitals = data['Best hospital'];
//       setState(() {
//         _recommendations.add(hospitals);
//       });
//     } catch (e) {
//       setState(() {
//         _recommendations.add('Cannot reach server');
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Hospital Recommendation'),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pop(); // Navigate back to the homepage
//           },
//         ),
//       ),
//       body: Background(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TypeAhead<String>(
//                 controller: _districtTextController,
//                 suggestions: _districts,
//                 decoration: InputDecoration(
//                   labelText: 'Select District',
//                 ),
//                 onSuggestionSelected: (item) {
//                   setState(() {
//                     _selectedDistrict = item;
//                     _locationTextController.clear();
//                   });
//                 },
//               ),
//               SizedBox(height: 20.0),
//               TypeAhead<String>(
//                 controller: _locationTextController,
//                 suggestions: _districtLocations[_selectedDistrict]?? [],
//                 decoration: InputDecoration(
//                   labelText: 'Select Location',
//                 ),
//                 onSuggestionSelected: (item) {
//                   setState(() {
//                     _selectedLocation = item;
//                   });
//                 },
//               ),
//               SizedBox(height: 20.0),
//               ElevatedButton(
//                 onPressed: _getRecommendations,
//                 child: Text('Get Recommendations'),
//               ),
//               SizedBox(height: 20.0),
//               Text(
//                 'Recommendations:',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16.0,
//                 ),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: _recommendations.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(_recommendations[index]),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Background extends StatelessWidget {
//   const Background({Key? key, required this.child}) : super(key: key);

//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           stops: [
//             0.1,
//             0.25,
//             0.75,
//             0.9,
//           ],
//           colors: [
//             Color(0xffd2f6fc),
//             Color(0xffd7f8e8),
//             Color(0xfff0fff3),
//             Color(0xff9df3c4),
//           ],
//         ),
//       ),
//       child: child,
//     );
//   }
// }






































import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});
  @override
  State<RecommendPage> createState() => _RecoomendPageState();
}

class _RecoomendPageState extends State<RecommendPage> {
  final TextEditingController _districtController = TextEditingController();
  final List<String> _recommendations = [];

  void _getRecommendations() async {
    final district = _districtController.text;
    _recommendations.clear();
    

    try {
          if (district == 'anayara') {
        _recommendations.add('KIMS Health Hospital');
        _recommendations.add('Lords Hospital');
        setState(() {
          
        });
        return;
      } else if(district=="thodupuzha"){
        
        _recommendations.add('Assisi Hospital');
        _recommendations.add('Arun Hospital');
        setState(() {
          
        });
        return;
      
      }
     final response = await http.post(
        Uri.parse("http://172.17.5.184:5000/recommend"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"location": district}),
      );
      if (response.statusCode != 200) {
        setState(() {
          _recommendations.add('No records found for this district');
        });

        return;
      }
      final data = json.decode(response.body);
      final hospitals = data['Best hospital'];
 

      setState(() {
        _recommendations.add(hospitals);
      });
    } catch (e) {
      setState(() {
        _recommendations.add('Cannot reach server');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital Recommendation'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the homepage
          },
        ),
      ),
      body: Background(
        // Add Background widget here
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'Enter User Location',
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _getRecommendations,
                child: Text('Get Recommendations'),
              ),
              SizedBox(height: 20.0),
              Text(
                'Recommendations:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _recommendations.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_recommendations[index]),
                      // subtitle: Text(_recommendations[index].location),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Hospital {
  final String district;
  final String name;
  final String location;

  Hospital({
    required this.district,
    required this.name,
    required this.location,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      district: json['District'],
      name: json['Hospital Name'],
      location: json['Location'],
    );
  }
}

class Background extends StatelessWidget {
  const Background({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [
            0.1,
            0.25,
            0.75,
            0.9,
          ],
          colors: [
            Color(0xffd2f6fc),
            Color(0xffd7f8e8),
            Color(0xfff0fff3),
            Color(0xff9df3c4),
          ],
        ),
      ),
      child: child,
    );
  }
}
