import 'package:flutter/material.dart';
import '../model/alamat_model.dart';
import '../model/city_model.dart';
import '../model/province_model.dart';
import '../services/alamat_service.dart';
import '../services/rajaongkir_service.dart';

class AlamatPage extends StatefulWidget {
  const AlamatPage({super.key});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {
  final AlamatService _alamatService = AlamatService();
  final RajaOngkirService _rajaOngkirService = RajaOngkirService();
  final _formKey = GlobalKey<FormState>();

  Alamat? _alamat;
  bool _isLoading = true;
  String? _errorMessage;

  // Form Controllers
  final _namaPenerimaController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatLengkapController = TextEditingController();
  final _kodePosController = TextEditingController();

  // RajaOngkir data
  List<Province> _provinces = [];
  List<City> _cities = [];
  Province? _selectedProvince;
  City? _selectedCity;

  bool _isProvinceLoading = true;
  bool _isCityLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Fetch address and provinces in parallel to save time
      final alamatFuture = _alamatService.getAlamat().catchError((e) {
        if (e.toString().contains('404')) {
          return null; // Not a fatal error, just means no address exists
        }
        throw e; // Rethrow other errors
      });
      final provincesFuture = _rajaOngkirService.getProvinces();

      final results = await Future.wait([alamatFuture, provincesFuture]);
      
      final alamat = results[0] as Alamat?;
      final provinces = results[1] as List<Province>;

      setState(() {
        _alamat = alamat;
        _provinces = provinces;
        _isProvinceLoading = false;

        if (_alamat != null) {
          _populateFormFields();
        }
      });

    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data awal: ${e.toString()}";
      });
    } finally {
       setState(() {
         _isLoading = false;
       });
    }
  }

  void _populateFormFields() {
    if (_alamat == null) return;

    _namaPenerimaController.text = _alamat!.namaPenerima;
    _noTelpController.text = _alamat!.noTelp;
    _alamatLengkapController.text = _alamat!.alamatLengkap;
    _kodePosController.text = _alamat!.kodePos;

    // Find and set the selected province
    try {
      _selectedProvince = _provinces.firstWhere((p) => p.provinceId == _alamat!.idProvinsi);
    } catch (e) {
      _selectedProvince = null;
    }
    
    // After setting province, fetch cities for it
    if (_selectedProvince != null) {
      _onProvinceChanged(_selectedProvince);
    }
  }

  Future<void> _onProvinceChanged(Province? province) async {
    if (province == null) return;

    // If the selected province is the same as the current one, do nothing.
    // This check is useful when populating the form.
    if (_selectedProvince?.provinceId == province.provinceId && _cities.isNotEmpty) return;

    setState(() {
      _selectedProvince = province;
      _selectedCity = null; // Reset city selection
      _cities = []; // Clear previous city list
      _isCityLoading = true;
      _errorMessage = null;
    });

    try {
      final cities = await _rajaOngkirService.getCities(province.provinceId);
      setState(() {
        _cities = cities;
        // If we are populating from an existing address, find and set the city
        if (_alamat != null && _alamat!.idProvinsi == province.provinceId) {
          try {
            _selectedCity = _cities.firstWhere((c) => c.cityId == _alamat!.idKota);
          } catch (e) {
            _selectedCity = null;
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data kota: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isCityLoading = false;
      });
    }
  }

  Future<void> _saveAlamat() async {
    // 1. Validate the form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 2. Create local variables to help with null analysis.
    final province = _selectedProvince;
    final city = _selectedCity;

    // 3. Explicitly check local variables.
    if (province == null || city == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih provinsi dan kota.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use local variables which are now guaranteed to be non-null.
      final newAlamat = Alamat(
        id: _alamat?.id,
        namaPenerima: _namaPenerimaController.text,
        noTelp: _noTelpController.text,
        alamatLengkap: _alamatLengkapController.text,
        kodePos: _kodePosController.text,
        idProvinsi: province.provinceId,
        namaProv: province.province,
        idKota: city.cityId,
        namaKota: city.cityName,
      );

      // 4. Handle create vs update with a safer ID check
      if (_alamat == null) {
        await _alamatService.createAlamat(newAlamat);
      } else {
        final alamatId = _alamat!.id;
        if (alamatId == null) {
          throw Exception('ID Alamat tidak ditemukan, tidak bisa memperbarui.');
        }
        await _alamatService.updateAlamat(alamatId, newAlamat);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat berhasil disimpan!')),
      );
      Navigator.pop(context, true);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Gagal menyimpan alamat: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _namaPenerimaController.dispose();
    _noTelpController.dispose();
    _alamatLengkapController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_alamat == null ? 'Tambah Alamat' : 'Ubah Alamat'),
        centerTitle: true,
      ),
      body: _isLoading && _provinces.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _provinces.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $_errorMessage'),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextFormField(_namaPenerimaController, 'Nama Penerima'),
                        const SizedBox(height: 16),
                        _buildTextFormField(_noTelpController, 'Nomor Telepon', keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildTextFormField(_alamatLengkapController, 'Alamat Lengkap', maxLines: 3),
                        const SizedBox(height: 16),
                        _buildProvinceDropdown(),
                        const SizedBox(height: 16),
                        _buildCityDropdown(),
                        const SizedBox(height: 16),
                        _buildTextFormField(_kodePosController, 'Kode Pos', keyboardType: TextInputType.number),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveAlamat,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white),
                                )
                              : const Text('Simpan Alamat'),
                        ),
                        if (_errorMessage != null && _provinces.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        ]
                      ],
                    ),
                  ),
                ),
    );
  }

  TextFormField _buildTextFormField(TextEditingController controller, String label, {int? maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) => value!.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }

  Widget _buildProvinceDropdown() {
    return DropdownButtonFormField<Province>(
      value: _selectedProvince,
      isExpanded: true,
      hint: const Text('Pilih Provinsi'),
      decoration: InputDecoration(
        labelText: 'Provinsi',
        border: const OutlineInputBorder(),
        prefixIcon: _isProvinceLoading ? const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ) : null,
      ),
      items: _provinces.map((Province province) {
        return DropdownMenuItem<Province>(
          value: province,
          child: Text(province.province),
        );
      }).toList(),
      onChanged: _isProvinceLoading ? null : _onProvinceChanged,
      validator: (value) => value == null ? 'Provinsi harus dipilih' : null,
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<City>(
      value: _selectedCity,
      isExpanded: true,
      hint: const Text('Pilih Kota/Kabupaten'),
      decoration: InputDecoration(
        labelText: 'Kota/Kabupaten',
        border: const OutlineInputBorder(),
        prefixIcon: _isCityLoading ? const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ) : null,
      ),
      items: _cities.map((City city) {
        return DropdownMenuItem<City>(
          value: city,
          child: Text(city.toString()),
        );
      }).toList(),
      onChanged: _selectedProvince == null || _isCityLoading ? null : (City? city) {
        setState(() {
          _selectedCity = city;
          if (city != null) {
            _kodePosController.text = city.postalCode;
          }
        });
      },
      validator: (value) => value == null ? 'Kota/Kabupaten harus dipilih' : null,
    );
  }
}
