-- Videos table to store video metadata
CREATE TABLE videos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT NOT NULL,
  video_url TEXT NOT NULL,
  view_count INTEGER DEFAULT 0,
  duration_seconds INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Video views table to track individual view events (for accurate counting)
CREATE TABLE video_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  video_id UUID NOT NULL REFERENCES videos(id) ON DELETE CASCADE,
  session_id TEXT NOT NULL,
  watched_at TIMESTAMPTZ DEFAULT now(),
  watch_duration_seconds INTEGER DEFAULT 0,
  counted BOOLEAN DEFAULT false
);

-- Index for faster lookups
CREATE INDEX idx_video_views_video_id ON video_views(video_id);
CREATE INDEX idx_video_views_session_id ON video_views(session_id);

-- Enable RLS
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_views ENABLE ROW LEVEL SECURITY;

-- Allow public read access to videos
CREATE POLICY "Videos are viewable by everyone" ON videos
  FOR SELECT USING (true);

-- Allow public to insert view records
CREATE POLICY "Anyone can record a view" ON video_views
  FOR INSERT WITH CHECK (true);

-- Allow public to read view records (for checking duplicates)
CREATE POLICY "Anyone can read view records" ON video_views
  FOR SELECT USING (true);

-- Function to record a view and increment count (only if minimum watch time met)
CREATE OR REPLACE FUNCTION record_video_view(
  p_video_id UUID,
  p_session_id TEXT,
  p_watch_duration INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_already_counted BOOLEAN;
  v_min_watch_seconds INTEGER := 3; -- Minimum 3 seconds to count as a view
BEGIN
  -- Check if this session already counted a view for this video
  SELECT EXISTS(
    SELECT 1 FROM video_views 
    WHERE video_id = p_video_id 
    AND session_id = p_session_id 
    AND counted = true
  ) INTO v_already_counted;
  
  -- If already counted, just update the watch duration
  IF v_already_counted THEN
    UPDATE video_views 
    SET watch_duration_seconds = GREATEST(watch_duration_seconds, p_watch_duration)
    WHERE video_id = p_video_id AND session_id = p_session_id;
    RETURN false;
  END IF;
  
  -- Check if watch duration meets minimum requirement
  IF p_watch_duration >= v_min_watch_seconds THEN
    -- Insert or update the view record
    INSERT INTO video_views (video_id, session_id, watch_duration_seconds, counted)
    VALUES (p_video_id, p_session_id, p_watch_duration, true)
    ON CONFLICT DO NOTHING;
    
    -- Increment the view count
    UPDATE videos SET view_count = view_count + 1 WHERE id = p_video_id;
    
    RETURN true;
  ELSE
    -- Record the view attempt but don't count it yet
    INSERT INTO video_views (video_id, session_id, watch_duration_seconds, counted)
    VALUES (p_video_id, p_session_id, p_watch_duration, false)
    ON CONFLICT DO NOTHING;
    
    RETURN false;
  END IF;
END;
$$;

-- Insert sample educational videos
INSERT INTO videos (title, description, thumbnail_url, video_url, duration_seconds) VALUES
('Ocean Waves', 'Relaxing ocean waves for meditation and focus', 'https://images.pexels.com/videos/1093662/free-video-1093662.jpg?auto=compress&cs=tinysrgb&w=400', 'https://videos.pexels.com/video-files/1093662/1093662-hd_1920_1080_30fps.mp4', 15),
('Mountain Sunrise', 'Beautiful sunrise over mountain peaks', 'https://images.pexels.com/videos/3015510/free-video-3015510.jpg?auto=compress&cs=tinysrgb&w=400', 'https://videos.pexels.com/video-files/3015510/3015510-hd_1920_1080_24fps.mp4', 20),
('Forest Walk', 'Peaceful walk through a green forest', 'https://images.pexels.com/videos/3571264/free-video-3571264.jpg?auto=compress&cs=tinysrgb&w=400', 'https://videos.pexels.com/video-files/3571264/3571264-hd_1920_1080_30fps.mp4', 18),
('City Lights', 'Night city timelapse with beautiful lights', 'https://images.pexels.com/videos/3129671/free-video-3129671.jpg?auto=compress&cs=tinysrgb&w=400', 'https://videos.pexels.com/video-files/3129671/3129671-hd_1920_1080_24fps.mp4', 22),
('Waterfall', 'Majestic waterfall in nature', 'https://images.pexels.com/videos/1409899/free-video-1409899.jpg?auto=compress&cs=tinysrgb&w=400', 'https://videos.pexels.com/video-files/1409899/1409899-hd_1920_1080_30fps.mp4', 16),
('Space Journey', 'Exploring the cosmos and stars', 'https://images.pexels.com/videos/3194277/free-video-3194277.jpg?auto=compress&cs=tinysrgb&w=400', 'https://videos.pexels.com/video-files/3194277/3194277-hd_1280_720_30fps.mp4', 25),
('Coffee Morning', 'Perfect morning coffee preparation', 'https://images.pexels.com/videos/5529604/free-video-5529604.jpg?auto=compress&cs=tinysrgb&w=400', 'https://videos.pexels.com/video-files/5529604/5529604-hd_1080_1920_25fps.mp4', 14),
('Autumn Leaves', 'Beautiful autumn colors and falling leaves', 'https://images.pexels.com/videos/5147952/free-video-5147952.jpg?auto=compress&cs=tinysrgb&w=400', 'https://videos.pexels.com/video-files/5147952/5147952-hd_1920_1080_25fps.mp4', 19),
('Ustoz AI Interview 1', 'Interview featuring Ustoz AI platform', '/9.png', 'https://pub-7f4e732999f740a39783172c306c439c.r2.dev/AQPYJZa6X1RxDwRQEyUziXiCUvAjUd9LcnKBQNdGBfc1Hb1VucwZIvqMQk1_aod.mp4', 0),
('Ustoz AI Interview 2', 'Interview session at Ustoz AI event', '/11.png', 'https://pub-7f4e732999f740a39783172c306c439c.r2.dev/IMG_1250.MOV', 0),
('Ustoz AI Interview 3', 'Educational interview content', '/12.png', 'https://pub-7f4e732999f740a39783172c306c439c.r2.dev/IMG_1251.MOV', 0),
('Ustoz AI Interview 4', 'Interview with educational insights', '/10.png', 'https://pub-7f4e732999f740a39783172c306c439c.r2.dev/IMG_1252.MOV', 0),
('Ustoz AI Interview 5', 'Interview session featuring Ustoz AI', '/13.png', 'https://pub-7f4e732999f740a39783172c306c439c.r2.dev/IMG_1253.MOV', 0),
('Ustoz AI Interview 6', 'Additional interview content', '/14.png', 'https://pub-7f4e732999f740a39783172c306c439c.r2.dev/IMG_1253.MOV', 0),
('Ustoz AI Interview 7', 'Final interview in the series', '/15.png', 'https://pub-7f4e732999f740a39783172c306c439c.r2.dev/IMG_1255.MOV', 0);

