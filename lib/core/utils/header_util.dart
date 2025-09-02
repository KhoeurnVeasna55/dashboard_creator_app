Map<String, String> header({required String token}) {
  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
