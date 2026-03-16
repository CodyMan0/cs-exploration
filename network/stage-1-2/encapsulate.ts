interface LayerData {
  header: string;
  payload: string;
}

function encapsulate(data: string, layers: string[]): LayerData[] {
  return layers.reduce((acc, layer) => {
    const payload =
      acc.length > 0
        ? `[${acc[acc.length - 1].header}|${acc[acc.length - 1].payload}]`
        : data;
    acc.push({
      header: `${layer}`,
      payload: payload,
    });
    return acc;
  }, [] as LayerData[]);
}

// 테스트
const result = encapsulate("Hello", ["TCP:8080", "IP:192.168.0.1", "ETH:AA:BB"]);
console.log(result);
// [
//   { header: "TCP:8080",       payload: "Hello" },
//   { header: "IP:192.168.0.1", payload: "[TCP:8080|Hello]" },
//   { header: "ETH:AA:BB",      payload: "[IP:192.168.0.1|[TCP:8080|Hello]]" }
// ]
