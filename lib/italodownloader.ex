defmodule Italodownloader do
  def get(url) do
    HTTPoison.get!(url, [], [ssl: [{:verify, :verify_none}], recv_timeout: 50000])
  end

  def downloadMusic(url) do
    IO.puts "Let's start grabbing some music from italo"
    get(url)
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
    body = get("https://portal.italolive.it/#{src}")
    |> Map.get(:body)

    File.write!(name, body)
    IO.puts "Done Downloading #{src}"
  end

  def downloadMovie(url) do
  end

  def downloadMovie do
    movieUrl = IO.gets("Navigate to the film you want to download and paste here the link: ")
    |> String.replace("\n", "")
    |> String.trim

    scripts = get(movieUrl)
    |> Map.get(:body)
    |> Floki.find("script")
    |> Floki.text([deep: true, js: true, sep: "media_server_api_endpoint"])
    case Regex.run(~r/http[s]?:\/\/[\S]+?\.mp4/, scripts) do
      url ->
        get(url)
      :error ->
        IO.puts "Error reading data."
    end
  end

  def start do
    # Set here the link of the radio category you want to download
    # If the music you need is not at page 1 add https://url/catrgory/categoryNumber/PageNumber
    what = IO.gets("What do you want to download?\nType 1 for music 2 for Movie then press enter: ") |> Integer.parse
    case what do
      { 1, _ } ->
        downloadMusic("https://portal.italolive.it/music/category/6")
      { 2, _ } -> downloadMovie
      :error ->
        "Bad input, you must type 1 or 2. Try again :D"
    end
  end
end
