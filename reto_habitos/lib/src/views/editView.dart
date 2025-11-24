
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reto_habitos/src/providers/habitosprovider.dart';
import '../models/HabitosModel.dart';

class EditView extends StatefulWidget {
  final Habito habito;

  const EditView({super.key, required this.habito});

  @override
  State<EditView> createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _duracionController;
  final HabitoProvider _provider = HabitoProvider();

  bool _isLoading = false;
  late DateTime _fechaInicio;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.habito.nombre);
    _descripcionController = TextEditingController(text: widget.habito.descripcion ?? '');
    _duracionController = TextEditingController(text: widget.habito.duracion.toString());
    _fechaInicio = widget.habito.fechaInicio;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 156, 175, 136),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Editar Hábito',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Nombre del Hábito'),
                const SizedBox(height: 12),
                _buildTextField(controller: _nombreController, hint: 'Ej: Meditación diaria', icon: Icons.short_text_rounded, validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingresa un nombre';
                  return null;
                }),
                const SizedBox(height: 24),
                _buildSectionTitle('Descripción'),
                const SizedBox(height: 12),
                _buildTextField(controller: _descripcionController, hint: 'Describe tu hábito...', icon: Icons.description_rounded, maxLines: 3),
                const SizedBox(height: 24),
                _buildSectionTitle('Duración diaria sugerida (minutos)'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _duracionController,
                  hint: 'Ej: 10',
                  icon: Icons.timer_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingresa la duración';
                    if (int.tryParse(value) == null) return 'Ingresa un número válido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Fecha de Inicio'),
                const SizedBox(height: 12),
                _buildDateSelector(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 45, 52, 54)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color.fromARGB(13, 0, 0, 0), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 45, 52, 54)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color.fromARGB(255, 189, 189, 189), fontSize: 16),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color.fromARGB(26, 156, 175, 136), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color.fromARGB(255, 156, 175, 136), size: 24),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color.fromARGB(255, 156, 175, 136), width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.red, width: 2)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.red, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [BoxShadow(color: Color.fromARGB(13, 0, 0, 0), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color.fromARGB(26, 161, 136, 199), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calendar_today, color: Color.fromARGB(255, 161, 136, 199), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _formatearFecha(_fechaInicio),
                  style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 45, 52, 54), fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color.fromARGB(255, 189, 189, 189)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 156, 175, 136),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Guardar Cambios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _fechaInicio = picked);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final fechaFin = _fechaInicio.add(const Duration(days: 30));

      final habitoActualizado = Habito(
        id: widget.habito.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        duracion: int.parse(_duracionController.text),
        fechaInicio: _fechaInicio,
        fechaFin: fechaFin,
        userId: widget.habito.userId,
        diasRealizados: widget.habito.diasRealizados,
        streakActual: widget.habito.streakActual,
        streakMaxima: widget.habito.streakMaxima,
      );

      await _provider.actualizarHabito(habitoActualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Hábito actualizado!'),
            backgroundColor: Color.fromARGB(255, 156, 175, 136),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar hábito: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatearFecha(DateTime fecha) {
    final meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    return '${fecha.day} de ${meses[fecha.month - 1]}, ${fecha.year}';
  }
}
