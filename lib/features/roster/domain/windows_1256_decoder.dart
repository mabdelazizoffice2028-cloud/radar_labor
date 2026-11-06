/// Decoder and encoder for Windows-1256 (CP1256) Arabic character set (B-010).
abstract final class Windows1256Decoder {
  static const _cp1256Mapping = <int>[
    8364, 1662, 8218, 402, 8222, 8230, 8224, 8225, 710, 8240, 1657, 8249, 338, 1670, 1688, 1672,
    1711, 8216, 8217, 8220, 8221, 8226, 8211, 8212, 1705, 8482, 1681, 8250, 339, 8204, 8205, 1722,
    160, 1548, 162, 163, 164, 165, 166, 167, 168, 169, 1726, 171, 172, 173, 174, 175,
    176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 1563, 187, 188, 189, 190, 1567,
    1729, 1569, 1570, 1571, 1572, 1573, 1574, 1575, 1576, 1577, 1578, 1579, 1580, 1581, 1582, 1583,
    1584, 1585, 1586, 1587, 1588, 1589, 1590, 215, 1591, 1592, 1593, 1594, 1600, 1601, 1602, 1603,
    224, 1604, 226, 1605, 1606, 1607, 1608, 231, 232, 233, 234, 235, 1609, 1610, 238, 239,
    1611, 1612, 1613, 1614, 244, 1615, 1616, 247, 1617, 249, 1618, 251, 252, 8206, 8207, 1746,
  ];

  static final Map<int, int> _reverseMap = {
    for (var i = 0; i < 128; i++) _cp1256Mapping[i]: 0x80 + i,
  };

  static String decode(List<int> bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      if (b < 0x80) {
        buffer.writeCharCode(b);
      } else if (b <= 0xFF) {
        buffer.writeCharCode(_cp1256Mapping[b - 0x80]);
      }
    }
    return buffer.toString();
  }

  static List<int> encode(String text) {
    final bytes = <int>[];
    for (final code in text.runes) {
      if (code < 0x80) {
        bytes.add(code);
      } else {
        bytes.add(_reverseMap[code] ?? 0x3F); // fallback to '?'
      }
    }
    return bytes;
  }
}
