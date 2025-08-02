import 'package:flutter/material.dart';
import 'package:flutter_application_latn/features/hospital/hospital_detail.dart';
import 'package:flutter_application_latn/features/hospital/models/hospital_model.dart';
import 'package:flutter_application_latn/features/hospital/services/hospital_service.dart';

class SearchHospital extends StatefulWidget {
  const SearchHospital({Key? key}) : super(key: key);

  @override
  State<SearchHospital> createState() => _SearchHospitalState();
}

class _SearchHospitalState extends State<SearchHospital> {
  List<Hospital> hospitals = [];
  List<Hospital> filteredHospitals = [];
  String searchQuery = '';
  bool isLoading = true;
  String? errorMessage;
  String? selectedSpecialty;
  double? minRating;

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

  void _filterHospitals(String query, {String? specialty, double? minRating}) {
    setState(() {
      searchQuery = query;
      selectedSpecialty = specialty ?? selectedSpecialty;
      this.minRating = minRating ?? this.minRating;
      filteredHospitals =
          hospitals.where((hospital) {
            final matchesQuery =
                query.isEmpty ||
                hospital.name.toLowerCase().contains(query.toLowerCase()) ||
                hospital.specialties.any(
                  (s) => s.toLowerCase().contains(query.toLowerCase()),
                );
            final matchesSpecialty =
                selectedSpecialty == null ||
                selectedSpecialty!.isEmpty ||
                hospital.specialties.any((s) => s == selectedSpecialty);
            final matchesRating =
                this.minRating == null || hospital.rate >= this.minRating!;
            return matchesQuery && matchesSpecialty && matchesRating;
          }).toList();
    });
  }

  void _showFilterModal() async {
    final specialties = hospitals.expand((h) => h.specialties).toSet().toList();
    String? tempSpecialty = selectedSpecialty;
    double? tempMinRating = minRating;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12 + MediaQuery.of(context).viewInsets.top,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chuyên khoa',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value:
                            tempSpecialty?.isEmpty == true
                                ? null
                                : tempSpecialty,
                        hint: const Text('Tất cả'),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Tất cả'),
                          ),
                          ...specialties
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            tempSpecialty = value == '' ? null : value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Text(
                        'Đánh giá tối thiểu',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: tempMinRating ?? 0,
                          min: 0,
                          max: 5,
                          divisions: 10,
                          label: (tempMinRating ?? 0).toStringAsFixed(1),
                          onChanged: (value) {
                            setModalState(() {
                              tempMinRating = value == 0 ? null : value;
                            });
                          },
                          activeColor: Colors.amber,
                          inactiveColor: Colors.amber[100],
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            (tempMinRating ?? 0) >= i + 1
                                ? Icons.star
                                : (tempMinRating ?? 0) > i
                                ? Icons.star_half
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (tempMinRating ?? 0).toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setModalState(() {
                            tempSpecialty = null;
                            tempMinRating = null;
                          });
                        },
                        icon: const Icon(Icons.clear, color: Colors.teal),
                        label: const Text(
                          'Xóa bộ lọc',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _filterHospitals(
                            searchQuery,
                            specialty: tempSpecialty,
                            minRating: tempMinRating,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Áp dụng',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tra cứu bệnh viện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    onChanged: (value) => _filterHospitals(value),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _showFilterModal,
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
                            fontSize: 16,
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
                            fontSize: 13,
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
                                      fontSize: 13,
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
                                  fontSize: 12,
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
                                    fontSize: 12,
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
