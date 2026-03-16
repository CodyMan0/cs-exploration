function isSameNetwork(ip1: string, ip2: string, mask: string): boolean {
  const ip1Array = ip1.split(".").map(Number);
  const ip2Array = ip2.split(".").map(Number);
  const maskArray = mask.split(".").map(Number);

  for (let i = 0; i < 4; i++) {
    if (maskArray[i] === 255) {
      if (ip1Array[i] !== ip2Array[i]) {
        return false;
      }
    }
  }
  return true;
}

// 테스트
console.log(isSameNetwork("192.168.0.10", "192.168.0.200", "255.255.255.0")); // true (같은 건물)
console.log(isSameNetwork("192.168.0.10", "192.168.1.10", "255.255.255.0")); // false (다른 건물)
