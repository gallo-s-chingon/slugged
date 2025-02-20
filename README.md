# slugged
revised version of benlinton/slugify

I'm mostly a prose writer, but nerdy enough to want to use nerdy tools, LLMs and distrohop to kill time. I don't recall when, but definitely aft 2014 I stumbled upon benlinton/slugify, it was great to be able to cut and paste clever strings for a blog title and be able to rename them to be used on a static site.

however comma, sometimes the filenames would contain emojis, non ASCII characters or punctuaction. Usually I'd roll with it until I got an error that my page/site didn't deploy and eventually learn that it was because it couldn't parse something (to do with the title) so I'd have to manually go back and rename the title. often times I'd use slugify first and then use Name Mangler on Mac OS to clean up the rest of the name. But like most *nix users i'd spend months tinkering with things so I can save 46 seconds in the future everytime i needed to `slugify` a filename.

I made a function to use slugify and a script to clean up the rest. now with LLMs it's easy to slap everything together and figured why not share this with the world?

TLDR - I started using slugyify, along with Name Mangler. then made a function and a script (with help from stack overflow) refined the script with ChatGPT/Perplexity, and Grok put it all together and basically told me to make a repo to share and eventually add to Homebrew.
