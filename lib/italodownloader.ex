defmodule Italodownloader do
  def downloadMusic(url) do
    IO.puts "Let's start grabbing some music from italo"
    HTTPoison.get!(url, [], [ssl: [{:verify, :verify_none}], recv_timeout: 50000])
    |> Map.get(:body)
    |> Floki.find(".AudioThumbnail img")
    |> Floki.attribute("src")
    |> thumbnailsToMp3
    |> spawnDownloads
  end

  def thumbnailsToMp3(thumbnails) do
    Enum.map thumbnails, fn thumbnail ->
      String.replace(thumbnail, "png", "mp3")
    end
  end

  def spawnDownloads(paths) do
    Enum.each paths, fn path ->
      spawn(Italodownloader, :download, [path])
    end
  end

  def download(src) do
    name = Path.basename(src)
    IO.puts "Downloading #{src} -> #{name}"
    body = HTTPoison.get!("https://portal.italolive.it/#{src}", [], [ssl: [{:verify, :verify_none}], recv_timeout: 50000])
    |> Map.get(:body)

    File.write!(name, body)
    IO.puts "Done Downloading #{src}"
  end

  def start do
    # Set here the link of the radio category you want to download
    # If the music you need is not at page 1 add https://url/catrgory/categoryNumber/PageNumber
    downloadMusic("https://portal.italolive.it/music/category/6")
  end
end
