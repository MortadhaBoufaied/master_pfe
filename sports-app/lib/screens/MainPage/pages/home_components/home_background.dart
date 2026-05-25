part of role_home_dashboard;

extension HomeBackground on _RoleHomeDashboardState {
  Widget homeBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            const Color(0xFFF4F7F7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background-image.png',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.20),
              colorBlendMode: BlendMode.dstATop,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -50,
            top: 120,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


