-- counts words in a document

words = 0

wordcount = {
  CodeBlock = function(el)
    _,n = el.text:gsub("%S+","")
    words = words + n
  end
}

function Pandoc(el)
    -- skip metadata, just count body:
    pandoc.walk_block(pandoc.Div(el.blocks), wordcount)
    print(words)
    os.exit(0)
end