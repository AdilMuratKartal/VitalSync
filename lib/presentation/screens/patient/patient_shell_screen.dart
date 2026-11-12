import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/appointment/appointment_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import '../../cubits/chat/chat_cubit.dart';
import '../../cubits/chat/chat_state.dart';
import '../../cubits/doctor_schedule/doctor_schedule_cubit.dart';
import '../../cubits/medical_records/medical_records_cubit.dart';
import '../../cubits/vital/vital_cubit.dart';

class PatientShellScreen extends StatelessWidget {
  static const String defaultDoctorId = 'dr_selin_yilmaz';

  final StatefulNavigationShell navigationShell;

  const PatientShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final authState = context.read<AuthCubit>().state;
    final initialUid = authState.authUid?.trim() ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<AppointmentCubit>(
          create: (_) {
            final cubit = AppointmentCubit();
            if (initialUid.isNotEmpty) {
              cubit.watchPatientAppointments(initialUid);
            }
            return cubit;
          },
        ),
        BlocProvider<DoctorScheduleCubit>(
          create: (_) {
            final cubit = DoctorScheduleCubit();
            if (initialUid.isNotEmpty) {
              cubit.watchDoctorSchedule(
                defaultDoctorId,
                watchAppointments: false,
              );
            }
            return cubit;
          },
        ),
        BlocProvider<MedicalRecordsCubit>(
          create: (_) {
            final cubit = MedicalRecordsCubit();
            if (initialUid.isNotEmpty) {
              cubit.watchPatientRecords(initialUid);
            }
            return cubit;
          },
        ),
        BlocProvider<VitalCubit>(
          create: (_) {
            final cubit = VitalCubit();
            if (initialUid.isNotEmpty) {
              cubit.watchPatientVitals(initialUid);
            }
            return cubit;
          },
        ),
        BlocProvider<ChatCubit>(
          create: (_) {
            final cubit = ChatCubit();
            if (initialUid.isNotEmpty) {
              cubit.watchConversation(
                patientId: initialUid,
                doctorId: defaultDoctorId,
              );
            }
            return cubit;
          },
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.authUid != current.authUid ||
            previous.isAuthenticated != current.isAuthenticated,
        listener: (context, state) {
          final uid = state.authUid?.trim() ?? '';
          if (state.isAuthenticated && uid.isNotEmpty) {
            context.read<AppointmentCubit>().watchPatientAppointments(uid);
            context.read<DoctorScheduleCubit>().watchDoctorSchedule(
                  defaultDoctorId,
                  watchAppointments: false,
                );
            context.read<MedicalRecordsCubit>().watchPatientRecords(uid);
            context.read<VitalCubit>().watchPatientVitals(uid);
            context.read<ChatCubit>().watchConversation(
                  patientId: uid,
                  doctorId: defaultDoctorId,
                );
          } else {
            context.read<AppointmentCubit>().reset();
            context.read<DoctorScheduleCubit>().reset();
            context.read<MedicalRecordsCubit>().reset();
            context.read<VitalCubit>().reset();
            context.read<ChatCubit>().reset();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: navigationShell,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.94),
              border: const Border(
                top: BorderSide(
                  color: AppColors.surfaceContainerHigh,
                  width: 1,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F131B2E),
                  blurRadius: 24,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 68,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Symbols.home,
                      label: 'Ana Sayfa',
                      isSelected: currentIndex == 0,
                      onTap: () => _onTap(0),
                    ),
                    _NavItem(
                      icon: Symbols.calendar_month,
                      label: 'Randevularım',
                      isSelected: currentIndex == 1,
                      onTap: () => _onTap(1),
                    ),
                    _NavItem(
                      icon: Symbols.lab_profile,
                      label: 'Sonuçlarım',
                      isSelected: currentIndex == 2,
                      onTap: () => _onTap(2),
                    ),
                    _NavItem(
                      icon: Symbols.monitoring,
                      label: 'Verilerim',
                      isSelected: currentIndex == 3,
                      onTap: () => _onTap(3),
                    ),
                    BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, chatState) {
                        final uid =
                            context.watch<AuthCubit>().state.authUid ?? '';
                        final hasUnread = uid.isNotEmpty
                            ? chatState.unreadCountForUser(uid) > 0
                            : true;
                        return _NavItem(
                          icon: Symbols.chat_bubble,
                          label: 'Mesajlaşma',
                          isSelected: currentIndex == 4,
                          showDot: hasUnread,
                          onTap: () => _onTap(4),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool showDot;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.showDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondaryContainer.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    fill: isSelected ? 1 : 0,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                if (showDot && !isSelected)
                  Positioned(
                    top: 2,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

