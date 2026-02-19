interface Packet {
  id: number;
  total: number;
  data: string;
}

function split(message: string, chunkSize: number): Packet[] {
  const packets: Packet[] = [];
  for (let i = 0; i < message.length; i += chunkSize) {
    packets.push({
      id: i / chunkSize,
      total: Math.ceil(message.length / chunkSize),
      data: message.slice(i, i + chunkSize),
    });
  }
  return packets;
}

function assemble(packets: Packet[]): string {
  return packets
    .sort((a, b) => a.id - b.id)
    .map((packet) => packet.data)
    .join("");
}

// 테스트
const packets = split("안녕하세요반갑습니다", 3);
console.log("패킷 분할:", packets);

const shuffled = [packets[2], packets[0], packets[3], packets[1]];
console.log("뒤죽박죽:", shuffled);
console.log("조립 결과:", assemble(shuffled));
