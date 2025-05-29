-- Enforce foreign key constraints
pragma foreign_keys = on;

create table feeds (
    id integer primary key autoincrement,
    url text not null,
    title text not null,
    description text,
    thumbnail_url text,
    added_at datetime not null
);

create table feed_items (
    id integer primary key autoincrement,
    feed_id integer not null,
    link text not null,
    title text not null,
    description text,
    image_url text,
    published_at datetime,
    created_at datetime not null,
    foreign key (feed_id) references feeds(id)
);

-- Create indexes on feed_items table (feed_id, created_at)
create index idx_feed_items_feed_id on feed_items(feed_id);
create index idx_feed_items_created_at on feed_items(created_at);

-- Create indexes on feeds table (url, title, added_at)
create index idx_feeds_url on feeds(url);
create index idx_feeds_title on feeds(title);
create index idx_feeds_added_at on feeds(added_at);