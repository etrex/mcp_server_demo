# 計算兩個數字總和的處理器
class CalculateSumHandler
  # 計算兩個數字的總和
  # @param a [Numeric] 第一個數字
  # @param b [Numeric] 第二個數字
  # @param env [String] 環境變數的 JSON 字串
  # @return [Array<Hash>] 包含計算結果的回應陣列
  def call(a: , b: , env:)
    [
      {
        type: "text",
        text: (a + b).to_s
      }
    ]
  end
end
