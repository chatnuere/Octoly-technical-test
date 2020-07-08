# Octoly Backend Challenge

## Backend Technical test

Statement of the exercice : 
[readme.md](https://github.com/octoly/jobs/blob/master/backend/README.md)

data provided with statement stored here : 
* [JSON](./videos.json)


### Exercice : 

[app.rb](./app.rb)

Open a terminal in the app.rb folder and launch this command

```bash
$ ruby app.rb
```

The terminal will prompt a Summary with the ID of the most viewed Topic with it's number of views

and a detailled hash with theses values

```ruby
{
  id:             string (id of the most viewed topic), 
  views_count:    integer, 
  likes_count:    integer, 
  dislikes_count: integer, 
  video_ids:      [array of video_ids where the most viewed topic is referenced], 
  topic_ids:      [array od topic_ids linked to the sames videos as the current topic]
}
```