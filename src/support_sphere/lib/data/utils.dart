import 'dart:convert';


// String token = response.session?.accessToken ?? '';
// Map<String, dynamic> decodedToken = Jwtdecode(token);

/// Decode a string JWT token into a `Map<String, dynamic>`
/// containing the decoded JSON payload.
///
/// Note: header and signature are not returned by this method.
///
/// Throws [FormatException] if parameter is not a valid JWT token.
Map<String, dynamic> Jwtdecode(String token) {
  final splitToken = token.split("."); // Split the token by '.'
  if (splitToken.length != 3) {
    throw const FormatException('Invalid token');
  }
  try {
    final payloadBase64 = splitToken[1]; // Payload is always the index 1
    // Base64 should be multiple of 4. Normalize the payload before decode it
    final normalizedPayload = base64.normalize(payloadBase64);
    // Decode payload, the result is a String
    final payloadString = utf8.decode(base64.decode(normalizedPayload));
    // Parse the String to a Map<String, dynamic>
    final decodedPayload = jsonDecode(payloadString);

    // Return the decoded payload
    return decodedPayload;
  } catch (error) {
    throw const FormatException('Invalid payload');
  }
}