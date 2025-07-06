import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Pharmacy {
  final String name;
  final double lat;
  final double lon;
  final String address;

  Pharmacy({
    required this.name,
    required this.lat,
    required this.lon,
    required this.address,
  });
}

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({Key? key}) : super(key: key);

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  GoogleMapController? _mapController;
  LatLng? _userLocation;
  List<Pharmacy> _pharmacies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _userLocation = LatLng(position.latitude, position.longitude);
      // Mock data for pharmacies (replace with real API call later)
      _pharmacies = [
        Pharmacy(
          name: 'Nhà thuốc Minh Châu',
          lat: position.latitude + 0.002,
          lon: position.longitude + 0.002,
          address: '123 Đường A, Quận 1',
        ),
        Pharmacy(
          name: 'Nhà thuốc Hồng Phát',
          lat: position.latitude - 0.001,
          lon: position.longitude - 0.001,
          address: '456 Đường B, Quận 3',
        ),
        Pharmacy(
          name: 'Nhà thuốc An Khang',
          lat: position.latitude + 0.0015,
          lon: position.longitude - 0.0015,
          address: '789 Đường C, Quận 5',
        ),
      ];
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(title: 'Vị trí của bạn'),
        ),
      );
    }
    for (final pharmacy in _pharmacies) {
      markers.add(
        Marker(
          markerId: MarkerId(pharmacy.name),
          position: LatLng(pharmacy.lat, pharmacy.lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: pharmacy.name,
            snippet: pharmacy.address,
          ),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm nhà thuốc gần nhất')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _userLocation!,
                        zoom: 15,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: _buildMarkers(),
                      onMapCreated: (controller) => _mapController = controller,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pharmacies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pharmacy = _pharmacies[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.local_pharmacy,
                              color: Colors.teal,
                              size: 32,
                            ),
                            title: Text(
                              pharmacy.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(pharmacy.address),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.directions,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                // Open Google Maps directions
                                final url =
                                    'https://www.google.com/maps/dir/?api=1&destination=${pharmacy.lat},${pharmacy.lon}';
                                // Use url_launcher to open (add dependency if needed)
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
