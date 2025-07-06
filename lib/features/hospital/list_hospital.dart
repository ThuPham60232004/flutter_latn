import 'package:flutter/material.dart';
import 'package:flutter_application_latn/features/hospital/hospital_detail.dart';
import 'package:flutter_application_latn/features/hospital/models/hospital_model.dart';
import 'package:flutter_application_latn/features/hospital/services/hospital_service.dart';
import 'package:flutter_application_latn/core/config/responsive_text.dart';

class ListHospitalPage extends StatefulWidget {
  const ListHospitalPage({Key? key}) : super(key: key);

  @override
  State<ListHospitalPage> createState() => _ListHospitalPageState();
}

class _ListHospitalPageState extends State<ListHospitalPage> {
  List<Hospital> hospitals = [];
  List<Hospital> filteredHospitals = [];
  String searchQuery = '';
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final hospitalsData = await HospitalService.getHospitals();

      setState(() {
        hospitals = hospitalsData;
        filteredHospitals = hospitalsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterHospitals(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredHospitals = hospitals;
      } else {
        filteredHospitals =
            hospitals.where((hospital) {
              return hospital.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  hospital.specialties.any(
                    (specialty) =>
                        specialty.toLowerCase().contains(query.toLowerCase()),
                  );
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách bệnh viện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadHospitals,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bệnh viện...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterHospitals,
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {}, // Add filter logic if needed
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.filter_list, color: Colors.teal),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildHospitalList()),
        ],
      ),
    );
  }

  Widget _buildHospitalList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHospitals,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (filteredHospitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isEmpty
                  ? Icons.local_hospital_outlined
                  : Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'Không có bệnh viện nào'
                  : 'Không tìm thấy bệnh viện',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Thử tìm kiếm với từ khóa khác',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredHospitals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final hospital = filteredHospitals[index];
        final hospitalData = hospital.toUIMap();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HospitalScreen(hospital: hospitalData),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child:
                      hospitalData['image']!.isNotEmpty
                          ? Image.network(
                            hospitalData['image']!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.teal,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildFallbackImage();
                            },
                          )
                          : _buildFallbackImage(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospitalData['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveText.h2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hospitalData['specialty']!,
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveText.bodyMedium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFF199A8E),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    hospitalData['rating']!,
                                    style: const TextStyle(
                                      color: Color(0xFF199A8E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: ResponsiveText.rating,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                hospitalData['location']!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: ResponsiveText.caption,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (hospital.phone.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: Colors.grey,
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  hospital.phone,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: ResponsiveText.caption,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_hospital, color: Colors.grey, size: 30),
          const SizedBox(height: 4),
          Text('Ảnh', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        ],
      ),
    );
  }
}

Widget _buildSectionTitle(String title, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            margin: const EdgeInsets.only(top: 2),
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListHospitalPage()),
          );
        },
        child: const Text('Xem tất cả', style: TextStyle(color: Colors.teal)),
      ),
    ],
  );
}
