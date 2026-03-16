class DNSCache {
  private cache = new Map<string, { ip: string; expireAt: number }>();

  set(domain: string, ip: string, ttl: number): void {
    this.cache.set(domain, { ip, expireAt: Date.now() + ttl * 1000 });
  }

  get(domain: string): string | null {
    const response = this.cache.get(domain);
    if (!response) return null;

    if (Date.now() > response.expireAt) return null;
    return response.ip;
  }
}

// 테스트
const cache = new DNSCache();
cache.set("google.com", "142.250.196.78", 5); // 5초 동안 유효
console.log(cache.get("google.com")); // → "142.250.196.78"

setTimeout(() => {
  console.log(cache.get("google.com")); // → null (5초 후 만료!)
}, 6000);
