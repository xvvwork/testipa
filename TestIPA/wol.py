from PIL import Image, ImageDraw, ImageFont
import os

# 获取当前脚本所在目录
dir_path = os.path.dirname(os.path.realpath(__file__))

# 遍历当前目录下的所有JPEG和PNG图片文件
for file_name in os.listdir(dir_path):
    if file_name.endswith('.jpeg') or file_name.endswith('.jpg') or file_name.endswith('.png'):
        img_path = os.path.join(dir_path, file_name)

        # 打开原始图片并获取宽高信息
        im = Image.open(img_path)
        width, height = im.size

        # 创建一个画布并在其上绘制文字
        txt = "Watermark"
        angle = 45
        font_size = 20
        font = ImageFont.truetype("arial.ttf", font_size)
        txt_width, txt_height = font.getsize(txt)
        txt_img = Image.new('RGBA', (txt_width, txt_height), (255, 255, 255, 0))
        txt_draw = ImageDraw.Draw(txt_img)
        txt_draw.text((0, 0), txt, font=font, fill=(255, 0, 0, 128))
        txt_img_rotated = txt_img.rotate(angle, expand=True)

        # 将水印添加到原始图片中
        spacing = 100
        for x in range(int(width / spacing)):
            for y in range(int(height / spacing)):
                pos = ((x + 1) * spacing - int(txt_width / 2), (y + 1) * spacing - int(txt_height / 2))
                im.paste(txt_img_rotated, pos, txt_img_rotated)

        # 保存加水印后的图片
        output_path = os.path.join(dir_path, 'watermarked_' + file_name)
        im.save(output_path)
