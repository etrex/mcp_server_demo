require 'base64'

# 讀取圖片並轉換為 Base64 的處理器
class ReadImageHandler
  # 讀取指定路徑的圖片並轉換為 Base64 格式
  # @param path [String] 圖片檔案的絕對路徑
  # @return [Array<Hash>] 包含圖片資料或錯誤訊息的回應陣列
  def call(path:)
    begin
      # 檢查檔案是否存在
      unless File.exist?(path)
        return [
          {
            type: "text",
            text: "錯誤：檔案不存在 (#{path})"
          }
        ]
      end
      
      # 檢查檔案是否為圖片
      mime_type = get_mime_type(path)
      unless mime_type.start_with?('image/')
        return [
          {
            type: "text",
            text: "錯誤：檔案不是有效的圖檔 (#{path})"
          }
        ]
      end
      
      # 讀取圖片並轉換成 base64
      image_data = File.binread(path)
      base64_data = Base64.strict_encode64(image_data)
      
      # 回傳結果
      [
        {
          type: "image",
          data: base64_data,
          mimeType: mime_type
        }
      ]
    rescue => e
      # 處理任何可能的錯誤
      [
        {
          type: "text",
          text: "發生錯誤：#{e.message}"
        }
      ]
    end
  end
  
  private
  
  # 使用檔案擴展名來判斷 MIME 類型
  # 根據檔案副檔名判斷 MIME 類型
  # @param file_path [String] 檔案路徑
  # @return [String] MIME 類型字串
  def get_mime_type(file_path)
    extension = File.extname(file_path).downcase
    case extension
    when '.jpg', '.jpeg'
      'image/jpeg'
    when '.png'
      'image/png'
    when '.gif'
      'image/gif'
    when '.bmp'
      'image/bmp'
    when '.webp'
      'image/webp'
    when '.svg'
      'image/svg+xml'
    when '.tiff', '.tif'
      'image/tiff'
    when '.ico'
      'image/x-icon'
    else
      # 如果不是已知的圖像類型，返回一個通用的 MIME 類型
      'application/octet-stream'
    end
  end
end
